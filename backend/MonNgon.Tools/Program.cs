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
    default:
        Console.Error.WriteLine("Lệnh: validate-data [thư mục] | engine-report [--data d] [--profiles f] [--seed n] [--only tên]");
        return 2;
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
