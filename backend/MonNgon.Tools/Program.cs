using MonNgon.Engine;
using MonNgon.Engine.Data;

// dotnet run --project backend/MonNgon.Tools -- validate-data [dir]
// dotnet run --project backend/MonNgon.Tools -- engine-report [--data data] [--profiles data/test-profiles.json] [--seed 1] [--only p01] [--meal-style auto|full_meal_only|mam_only]
Console.OutputEncoding = System.Text.Encoding.UTF8;
var cmd = args.Length > 0 ? args[0] : "";
switch (cmd)
{
    case "validate-data":
        return ValidateData(args.Length > 1 ? args[1] : "data");
    case "engine-report":
        return EngineReportCmd(args.Skip(1).ToArray());
    case "bench":
        return Bench(args.Skip(1).ToArray());
    case "sweep":
        return Sweep(args.Skip(1).ToArray());
    case "determinism":
        return Determinism(args.Skip(1).ToArray());
    default:
        Console.Error.WriteLine("Lệnh: validate-data [thư mục] | engine-report [--data d] [--profiles f] [--seed n] [--only tên] | bench [--data d] [--profiles f] [--seeds 1,2,3] [--only tên] [--max-ms n] [--p95-ms n]");
        return 2;
}

// T-101: đo thời gian lập tuần (WeekPlanner.Plan, như POST /v1/plans) cho mọi hồ sơ × 4 mức cơm × các seed, chạy lần lượt (không chồng nhau).
// Chạy một lượt khởi động trước để JIT không tính vào số đo. Trả mã 1 nếu max/p95 vượt ngưỡng (--max-ms, --p95-ms; 0 = không kiểm).
static int Bench(string[] a)
{
    string Opt(string name, string def)
    {
        var i = Array.IndexOf(a, "--" + name);
        return i >= 0 && i + 1 < a.Length ? a[i + 1] : def;
    }
    var dataDir = Opt("data", "data");
    var ds = Dataset.LoadDirectory(dataDir);
    var only = Opt("only", "");
    var seeds = Opt("seeds", "1,2,3").Split(',', StringSplitOptions.RemoveEmptyEntries).Select(long.Parse).ToList();
    var maxMs = double.Parse(Opt("max-ms", "0"), System.Globalization.CultureInfo.InvariantCulture);
    var p95Ms = double.Parse(Opt("p95-ms", "0"), System.Globalization.CultureInfo.InvariantCulture);
    var cpuP95Ms = double.Parse(Opt("cpu-p95-ms", "0"), System.Globalization.CultureInfo.InvariantCulture);
    var levels = Opt("levels", string.Join(',', MonNgon.Engine.Types.Enums.RiceHabits)).Split(',', StringSplitOptions.RemoveEmptyEntries);
    var profiles = TestProfile.LoadFile(Opt("profiles", Path.Combine(dataDir, "test-profiles.json"))).Where(p => only.Length == 0 || p.Id.Contains(only)).ToList();
    var options = new PlanOptions { RiceOnlyAttempt = int.Parse(Opt("attempt", "0")), LiftToLowerLevel = Opt("lift", "true") != "false", MaxParallelAttempts = int.Parse(Opt("par", "2")), DayParallelism = int.Parse(Opt("daypar", "-1")), SkipRankedOverBudgetRatio = double.Parse(Opt("skip", "0"), System.Globalization.CultureInfo.InvariantCulture), WaitForRicePresence = Opt("wait", "true") != "false" };
    PlanWeekInput Input(TestProfile tp, string level, long seed)
    {
        var prefs = System.Text.Json.JsonSerializer.Deserialize<MonNgon.Engine.Types.Preferences>(System.Text.Json.JsonSerializer.Serialize(tp.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        prefs.RiceHabit = level;
        return new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = prefs, Data = ds, StartDate = "2026-11-09", Seed = seed, Options = options };
    }
    if (profiles.Count > 0) WeekPlanner.Plan(Input(profiles[0], "it", 1));
    var proc = System.Diagnostics.Process.GetCurrentProcess();
    var rows = new List<(string Id, string Level, long Seed, double Ms, double CpuMs, string Status, int Attempt, int Iter)>();
    var editRows = new List<(string Id, string Level, long Seed, string Kind, double Ms)>();
    foreach (var tp in profiles)
        foreach (var level in levels)
            foreach (var seed in seeds)
            {
                proc.Refresh();
                var cpu0 = proc.TotalProcessorTime;
                var sw = System.Diagnostics.Stopwatch.StartNew();
                var plan = WeekPlanner.Plan(Input(tp, level, seed));
                var ms = sw.Elapsed.TotalMilliseconds;
                proc.Refresh();
                rows.Add((tp.Id, level, seed, ms, (proc.TotalProcessorTime - cpu0).TotalMilliseconds, plan.Status, plan.RiceAttempt, plan.Iterations));
                if (a.Contains("--edits") && plan.Status == "ready")
                {
                    var inp0 = Input(tp, level, seed);
                    var einp = new EditInput { Targets = inp0.Targets, Prefs = inp0.Prefs, Data = ds, Plan = plan };
                    var lunch = plan.Days[2].Meals.First(m => m.Slot == "lunch" && m.Status == "planned");
                    var sw2 = System.Diagnostics.Stopwatch.StartNew();
                    var sug = WeekPlanner.SuggestSwaps(einp, lunch.Date, "lunch");
                    editRows.Add((tp.Id, level, seed, "suggest", sw2.Elapsed.TotalMilliseconds));
                    if (sug.Items.Count > 0)
                    {
                        sw2.Restart();
                        WeekPlanner.ApplySwap(einp, lunch.Date, "lunch", sug.Items[0].RecipeId);
                        editRows.Add((tp.Id, level, seed, "swap", sw2.Elapsed.TotalMilliseconds));
                    }
                    foreach (var keep in new[] { 0, 3 })
                    {
                        sw2.Restart();
                        WeekPlanner.RegenerateRest(einp, plan.Days[keep].Date);
                        editRows.Add((tp.Id, level, seed, keep == 0 ? "regen6" : "regen3", sw2.Elapsed.TotalMilliseconds));
                    }
                }
                if (a.Contains("--rows")) Console.WriteLine($"{tp.Id} {level} seed {seed}: {ms:0} ms cpu {(proc.TotalProcessorTime - cpu0).TotalMilliseconds:0} {plan.Status} attempt {plan.RiceAttempt} iter {plan.Iterations}{(a.Contains("--hash") ? " hash " + Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(System.Text.Json.JsonSerializer.Serialize(plan, JsonOptions.Default))))[..12] : "")}");
            }
    Console.WriteLine($"Số lõi: {Environment.ProcessorCount}; {profiles.Count} hồ sơ × {levels.Length} mức × {seeds.Count} seed = {rows.Count} lần lập");
    Console.WriteLine("mức        | số lần |  p50 ms |  p95 ms |  max ms | cpu p95 ms | cpu max ms");
    static double Pct(IEnumerable<double> xs, double p)
    {
        var s = xs.OrderBy(x => x).ToList();
        return s.Count == 0 ? 0 : s[Math.Min(s.Count - 1, (int)Math.Ceiling(p * s.Count) - 1)];
    }
    foreach (var level in levels.Append("*"))
    {
        var r = rows.Where(x => level == "*" || x.Level == level).ToList();
        Console.WriteLine($"{(level == "*" ? "tất cả" : level),-10} | {r.Count,6} | {Pct(r.Select(x => x.Ms), 0.5),7:0} | {Pct(r.Select(x => x.Ms), 0.95),7:0} | {r.Max(x => x.Ms),7:0} | {Pct(r.Select(x => x.CpuMs), 0.95),10:0} | {r.Max(x => x.CpuMs),10:0}");
    }

    if (editRows.Count > 0)
    {
        Console.WriteLine("Chỉnh tuần (mỗi thao tác tính riêng):");
        foreach (var kind in editRows.Select(x => x.Kind).Distinct())
        {
            var r = editRows.Where(x => x.Kind == kind).ToList();
            Console.WriteLine($"  {kind,-8} n={r.Count,4} p50 {Pct(r.Select(x => x.Ms), 0.5),6:0} ms · p95 {Pct(r.Select(x => x.Ms), 0.95),6:0} ms · max {r.Max(x => x.Ms),6:0} ms");
        }
        foreach (var x in editRows.OrderByDescending(x => x.Ms).Take(5)) Console.WriteLine($"  chậm: {x.Id} {x.Level} seed {x.Seed} {x.Kind} {x.Ms:0} ms");
    }
    Console.WriteLine("Chậm nhất:");
    foreach (var x in rows.OrderByDescending(x => x.Ms).Take(8)) Console.WriteLine($"  {x.Id} {x.Level} seed {x.Seed}: {x.Ms:0} ms (cpu {x.CpuMs:0}) {x.Status} attempt {x.Attempt} iter {x.Iter}");
    var all = rows.Select(x => x.Ms).ToList();
    var bad = (maxMs > 0 && all.Max() > maxMs) || (p95Ms > 0 && Pct(all, 0.95) > p95Ms) || (cpuP95Ms > 0 && Pct(rows.Select(x => x.CpuMs), 0.95) > cpuP95Ms);
    if (bad) Console.WriteLine($"VƯỢT NGƯỠNG: max {all.Max():0} ms (ngưỡng {maxMs:0}), p95 {Pct(all, 0.95):0} ms (ngưỡng {p95Ms:0}), cpu p95 {Pct(rows.Select(x => x.CpuMs), 0.95):0} ms (ngưỡng {cpuP95Ms:0})");
    return bad ? 1 : 0;
}

static int ValidateData(string dir)
{
    RawDataset raw;
    try { raw = RawDataset.ReadDirectory(dir); }
    catch (Exception e) when (e is IOException or System.Text.Json.JsonException)
    {
        Console.Error.WriteLine($"Không đọc được dữ liệu trong \"{dir}\": {e.Message}");
        return 2;
    }
    var res = DataValidator.Validate(raw);
    foreach (var i in res.Issues) Console.WriteLine(i);
    Console.WriteLine($"\n{dir}: {res.Errors} lỗi, {res.Warnings} cảnh báo.");
    return res.Errors > 0 ? 1 : 0;
}

static int EngineReportCmd(string[] a)
{
    string Opt(string name, string def)
    {
        var i = Array.IndexOf(a, "--" + name);
        return i >= 0 && i + 1 < a.Length ? a[i + 1] : def;
    }
    var dataDir = Opt("data", "data");
    var ds = Dataset.LoadDirectory(dataDir);
    var seed = long.Parse(Opt("seed", "1"));
    var only = Opt("only", "");
    var profiles = TestProfile.LoadFile(Opt("profiles", Path.Combine(dataDir, "test-profiles.json"))).Where(p => only.Length == 0 || p.Id.Contains(only)).ToList();
    if (!MealStyles.TryParse(Opt("meal-style", "auto"), out var style))
    {
        Console.Error.WriteLine("--meal-style phải là auto | full_meal_only | mam_only");
        return 2;
    }
    var rice = Opt("rice", "");
    if (rice.Length > 0)
    {
        if (!MonNgon.Engine.Types.Enums.RiceHabits.Contains(rice)) { Console.Error.WriteLine("--rice phải là it | vua | nhieu | rat_nhieu"); return 2; }
        foreach (var p in profiles) p.Preferences.RiceHabit = rice;
    }
    var options = new PlanOptions { MealStyle = style, RiceKeepFirst = Opt("rice-keep-first", "true") != "false", RiceOnlyAttempt = int.Parse(Opt("rice-attempt", "0")), LiftToLowerLevel = Opt("lift", "true") != "false", RiceKcalShift = double.Parse(Opt("rice-shift", "0.15"), System.Globalization.CultureInfo.InvariantCulture) };
    var results = profiles.Select(p => EngineReport.RunProfile(p, ds, seed, "2026-11-09", options, new EngineReport.ReportExtras(a.Contains("--relaxed"), a.Contains("--levels")))).ToList();
    Console.WriteLine(EngineReport.Format(results));
    if (a.Contains("--days"))
        foreach (var tp in profiles)
        {
            var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = tp.Preferences, Data = ds, StartDate = "2026-11-09", Seed = seed, Options = options });
            Console.WriteLine($"--- {tp.Id} rice={tp.Preferences.RiceHabit}");
            foreach (var d in plan.Days)
            {
                Console.WriteLine($"{d.Date} kcal {d.Totals.Kcal:0} prot {d.Totals.ProteinG:0}");
                foreach (var m in d.Meals.Where(m => m.Status == "planned"))
                    Console.WriteLine($"   {m.Slot,-9} {m.Macros.Kcal,5:0} kcal {m.Macros.ProteinG,4:0} g  {(m.Rice is null ? "-" : $"cơm {m.Rice.ActualG:0}/{m.Rice.TargetG:0} {(m.Notes is null ? "" : "NOTE " + m.Notes[0].Reason)}")}  {m.RecipeId}");
            }
        }


    return EngineReport.Summarize(results).HardViolations > 0 ? 1 : 0;
}

// T-104: quét ngân sách của một hồ sơ (chẩn đoán): với mỗi ngân sách in trạng thái, chi phí, số bữa trưa/tối ghép mâm, có cơm, số món trưa/tối khác nhau.
// sweep [--data d] [--only p01] [--habit vua] [--adults n] [--children n] [--from 600000 --to 800000 --step 25000] [--seed 1]
static int Sweep(string[] a)
{
    string Opt(string name, string def)
    {
        var i = Array.IndexOf(a, "--" + name);
        return i >= 0 && i + 1 < a.Length ? a[i + 1] : def;
    }
    var ds = Dataset.LoadDirectory(Opt("data", "data"));
    var tp = TestProfile.LoadFile(Path.Combine(Opt("data", "data"), "test-profiles.json")).First(p => p.Id.StartsWith(Opt("only", "p01"), StringComparison.Ordinal));
    var from = int.Parse(Opt("from", "600000")); var to = int.Parse(Opt("to", "800000")); var step = int.Parse(Opt("step", "25000"));
    for (var b = from; b <= to; b += step)
    {
        var prefs = System.Text.Json.JsonSerializer.Deserialize<MonNgon.Engine.Types.Preferences>(System.Text.Json.JsonSerializer.Serialize(tp.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        prefs.WeeklyBudgetVnd = b;
        if (Opt("habit", "") != "") prefs.RiceHabit = Opt("habit", "");
        if (Opt("adults", "") != "") prefs.Adults = int.Parse(Opt("adults", "1"));
        if (Opt("children", "") != "") prefs.Children = int.Parse(Opt("children", "0"));
        var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = prefs, Data = ds, StartDate = "2026-11-09", Seed = long.Parse(Opt("seed", "1")), Options = Opt("attempt", "") != "" ? new PlanOptions { RiceOnlyAttempt = int.Parse(Opt("attempt", "0")), RepairIterations = int.Parse(Opt("repairit", "30")), RepairMealsPerIter = int.Parse(Opt("repairmeals", "20")), RepairRecipeAlts = int.Parse(Opt("repairalts", "20")) } : null });
        var ld = plan.Days.SelectMany(d => d.Meals).Where(m => m.Slot is "lunch" or "dinner" && m.Status == "planned" && m.RecipeId is not null).ToList();
        var mam = ld.Count(m => m.Dishes?.Any(x => x.Role == "main") ?? false);
        Console.WriteLine($"{b,9} {plan.Status,-7} cost {plan.Shopping.WeekFoodCost,9:0} mâm {mam,2}/{ld.Count} cơm {ld.Count(m => m.Rice is not null),2} món {ld.Select(m => m.RecipeId).Distinct().Count(),2} attempt {plan.RiceAttempt}");
    }
    return 0;
}

// T-104/PM: kiểm tính tất định — mỗi ô (hồ sơ × mức cơm × seed) lập --repeat lần (mặc định 20; các phương án/ngày vẫn chạy song song như thật) và so băm JSON của tuần.
// determinism [--data d] [--only tên] [--seeds 1,2,3] [--levels it,vua,...] [--repeat 20]. Mã thoát 1 nếu có ô cho kết quả khác nhau.
static int Determinism(string[] a)
{
    string Opt(string name, string def)
    {
        var i = Array.IndexOf(a, "--" + name);
        return i >= 0 && i + 1 < a.Length ? a[i + 1] : def;
    }
    var dataDir = Opt("data", "data");
    var ds = Dataset.LoadDirectory(dataDir);
    var only = Opt("only", "");
    var seeds = Opt("seeds", "1,2,3").Split(',', StringSplitOptions.RemoveEmptyEntries).Select(long.Parse).ToList();
    var levels = Opt("levels", string.Join(',', MonNgon.Engine.Types.Enums.RiceHabits)).Split(',', StringSplitOptions.RemoveEmptyEntries);
    var repeat = int.Parse(Opt("repeat", "20"));
    var profiles = TestProfile.LoadFile(Path.Combine(dataDir, "test-profiles.json")).Where(p => only.Length == 0 || p.Id.Contains(only)).ToList();
    var cells = 0; var bad = 0;
    foreach (var tp in profiles)
        foreach (var level in levels)
            foreach (var seed in seeds)
            {
                var hashes = new Dictionary<string, int>();
                for (var k = 0; k < repeat; k++)
                {
                    var prefs = System.Text.Json.JsonSerializer.Deserialize<MonNgon.Engine.Types.Preferences>(System.Text.Json.JsonSerializer.Serialize(tp.Preferences, JsonOptions.Default), JsonOptions.Default)!;
                    prefs.RiceHabit = level;
                    var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = prefs, Data = ds, StartDate = "2026-11-09", Seed = seed });
                    var h = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(System.Text.Json.JsonSerializer.Serialize(plan, JsonOptions.Default))))[..12] + $" {plan.Status} attempt {plan.RiceAttempt} cost {plan.Shopping.WeekFoodCost:0}";
                    hashes[h] = hashes.GetValueOrDefault(h) + 1;
                }
                cells++;
                if (hashes.Count > 1) { bad++; Console.WriteLine($"KHÁC NHAU {tp.Id} {level} seed {seed}: " + string.Join(" | ", hashes.Select(x => $"{x.Key} ×{x.Value}"))); }
            }
    Console.WriteLine($"{cells} ô × {repeat} lần; ô không tất định: {bad}");
    return bad > 0 ? 1 : 0;
}
