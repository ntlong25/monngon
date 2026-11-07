using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-062…T-064 — khớp golden/ do engine TS (tham chiếu) xuất ra.</summary>
public sealed class GoldenFixture
{
    public Dataset Data { get; } = Dataset.LoadDirectory(TestPaths.Data);
    public JsonNode Manifest { get; } = JsonNode.Parse(File.ReadAllText(Path.Combine(TestPaths.Golden, "manifest.json")))!;
}

public static class GoldenJson
{
    /// <summary>Sai số cho phép với macro (≤ 1e-6); chi phí/gram/số gói phải khớp tuyệt đối.</summary>
    public const double MacroTolerance = 1e-6;

    private static readonly Dictionary<string, string> KeyAlias = new() { ["byAisle"] = "by_aisle" };

    public static JsonNode? ToNode<T>(T value) => JsonSerializer.SerializeToNode(value, JsonOptions.Default);

    public static JsonNode Read(string rel) => JsonNode.Parse(File.ReadAllText(Path.Combine(TestPaths.Golden, rel)))!;

    private static bool Exact(string path) =>
        path.Contains("cost", StringComparison.Ordinal) || path.Contains("_vnd", StringComparison.Ordinal) ||
        path.EndsWith("grams", StringComparison.Ordinal) || path.Contains(".grams[", StringComparison.Ordinal) ||
        path.EndsWith(".packs", StringComparison.Ordinal) || path.EndsWith("seed", StringComparison.Ordinal);

    public static void Diff(JsonNode? expected, JsonNode? actual, string path, List<string> diffs)
    {
        if (diffs.Count >= 20) return;
        switch (expected)
        {
            case null:
                if (actual is not null) diffs.Add($"{path}: kỳ vọng null, nhận {actual.ToJsonString()}");
                return;
            case JsonObject eo:
            {
                if (actual is not JsonObject ao) { diffs.Add($"{path}: kỳ vọng object"); return; }
                var expKeys = eo.Select(kv => KeyAlias.GetValueOrDefault(kv.Key, kv.Key)).OrderBy(k => k, StringComparer.Ordinal).ToList();
                var actKeys = ao.Select(kv => kv.Key).OrderBy(k => k, StringComparer.Ordinal).ToList();
                if (!expKeys.SequenceEqual(actKeys))
                {
                    diffs.Add($"{path}: khóa khác nhau. thiếu [{string.Join(",", expKeys.Except(actKeys))}] thừa [{string.Join(",", actKeys.Except(expKeys))}]");
                    return;
                }
                foreach (var kv in eo) Diff(kv.Value, ao[KeyAlias.GetValueOrDefault(kv.Key, kv.Key)], $"{path}.{kv.Key}", diffs);
                return;
            }
            case JsonArray ea:
            {
                if (actual is not JsonArray aa) { diffs.Add($"{path}: kỳ vọng mảng"); return; }
                if (ea.Count != aa.Count) { diffs.Add($"{path}: độ dài {ea.Count} ≠ {aa.Count}"); return; }
                for (var i = 0; i < ea.Count; i++) Diff(ea[i], aa[i], $"{path}[{i}]", diffs);
                return;
            }
            case JsonValue ev:
            {
                if (actual is not JsonValue av) { diffs.Add($"{path}: kỳ vọng giá trị"); return; }
                var e = ev.GetValue<JsonElement>();
                var a = av.GetValue<JsonElement>();
                if (e.ValueKind == JsonValueKind.Number)
                {
                    if (a.ValueKind != JsonValueKind.Number) { diffs.Add($"{path}: kỳ vọng số"); return; }
                    var x = e.GetDouble();
                    var y = a.GetDouble();
                    var tol = Exact(path) ? 0 : MacroTolerance;
                    if (Math.Abs(x - y) > tol) diffs.Add($"{path}: {x:R} ≠ {y:R}");
                    return;
                }
                if (e.ValueKind != a.ValueKind || e.ToString() != a.ToString()) diffs.Add($"{path}: {e} ≠ {a}");
                return;
            }
        }
    }

    public static void AssertSame(JsonNode? expected, JsonNode? actual, string what)
    {
        var diffs = new List<string>();
        Diff(expected, actual, what, diffs);
        Assert.True(diffs.Count == 0, string.Join("\n", diffs));
    }
}

public class GoldenVectorTests(GoldenFixture fx) : IClassFixture<GoldenFixture>
{
    [Fact]
    public void Golden_cung_phien_ban_du_lieu()
    {
        var files = Directory.GetFiles(TestPaths.Data, "*.json").Select(Path.GetFileName).OrderBy(n => n, StringComparer.Ordinal).ToList();
        using var sha = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        foreach (var name in files)
        {
            var content = File.ReadAllText(Path.Combine(TestPaths.Data, name!), Encoding.UTF8);
            sha.AppendData(Encoding.UTF8.GetBytes(name + "\0" + content + "\0"));
        }
        var version = Convert.ToHexString(sha.GetHashAndReset()).ToLowerInvariant();
        Assert.True(version == fx.Manifest["data_version_sha256"]!.GetValue<string>(),
            "data/*.json đã đổi so với golden/ → chạy `npm run export-golden` ở thư mục gốc repo rồi chạy lại test");
    }

    [Theory]
    [InlineData("1")]
    [InlineData("42")]
    public void Rng_1000_gia_tri_dau(string seed)
    {
        var g = GoldenJson.Read("vectors/rng.json");
        var expected = g["seeds"]![seed]!.AsArray();
        var rng = new Rng(long.Parse(seed));
        Assert.Equal(1000, expected.Count);
        for (var i = 0; i < expected.Count; i++) Assert.Equal(expected[i]!.GetValue<double>(), rng.Next());
    }

    [Fact]
    public void DeriveSeed_khop()
    {
        foreach (var row in GoldenJson.Read("vectors/rng.json")["derive_seed"]!.AsArray())
        {
            var seed = row!["seed"]!.GetValue<long>();
            var values = row["values"]!.AsArray();
            for (var n = 0; n < values.Count; n++) Assert.Equal(values[n]!.GetValue<double>(), (double)Rng.DeriveSeed(seed, n));
        }
    }

    [Fact]
    public void Js_round_va_calorie_band()
    {
        var g = GoldenJson.Read("vectors/targets.json");
        foreach (var row in g["js_round"]!.AsArray()) Assert.Equal(row!["round"]!.GetValue<double>(), Js.Round(row["x"]!.GetValue<double>()));
        foreach (var row in g["calorie_band"]!.AsArray())
        {
            var kcal = row!["kcal"]!.GetValue<double>();
            var d = TargetCalc.CalorieBand(kcal);
            Assert.Equal((row["default"]!["kcal_min"]!.GetValue<double>(), row["default"]!["kcal_max"]!.GetValue<double>()), d);
            var l = TargetCalc.CalorieBand(kcal, new TargetOptions { BandAbovePct = 0 });
            Assert.Equal((row["legacy_minus5_0"]!["kcal_min"]!.GetValue<double>(), row["legacy_minus5_0"]!["kcal_max"]!.GetValue<double>()), l);
        }
    }

    [Fact]
    public void Targets_cac_ho_so()
    {
        foreach (var row in GoldenJson.Read("vectors/targets.json")["profiles"]!.AsArray())
        {
            var profile = row!["profile"].Deserialize<Profile>(JsonOptions.Default)!;
            var t = TargetCalc.Compute(profile);
            GoldenJson.AssertSame(row["targets"], GoldenJson.ToNode(t), $"targets[{row["id"]}]");
            if (profile.TargetMode != "manual") Assert.Equal(row["bmr"]!.GetValue<double>(), TargetCalc.Bmr(profile));
            Assert.Equal(row["reference_weight_kg"]!.GetValue<double>(), TargetCalc.ReferenceWeightKg(profile));
        }
    }

    [Fact]
    public void Slots_cac_ho_so()
    {
        foreach (var row in GoldenJson.Read("vectors/slots.json").AsArray())
        {
            var cfg = row!["slots_config"].Deserialize<SlotsConfig>(JsonOptions.Default)!;
            var profile = GoldenJson.Read("vectors/targets.json")["profiles"]!.AsArray().First(p => p!["id"]!.GetValue<string>() == row["id"]!.GetValue<string>())!["profile"].Deserialize<Profile>(JsonOptions.Default)!;
            var slots = MealSlots.Allocate(TargetCalc.Compute(profile), cfg);
            GoldenJson.AssertSame(row["slots"], GoldenJson.ToNode(slots), $"slots[{row["id"]}]");
        }
    }

    [Fact]
    public void Nutrition_khau_phan_chuan()
    {
        foreach (var row in GoldenJson.Read("vectors/nutrition.json").AsArray())
        {
            var recipe = fx.Data.RecipesById[row!["recipe_id"]!.GetValue<string>()];
            var res = Nutrition.Compute(Nutrition.RecipeBaseLines(recipe), fx.Data.IngredientsById);
            GoldenJson.AssertSame(row["result"], GoldenJson.ToNode(res), $"nutrition[{recipe.Id}]");
        }
    }

    [Fact]
    public void Scale_cac_cong_thuc()
    {
        var rows = GoldenJson.Read("vectors/scale.json").AsArray();
        Assert.True(rows.Count > 500);
        foreach (var row in rows)
        {
            var recipe = fx.Data.RecipesById[row!["recipe_id"]!.GetValue<string>()];
            var target = new ScaleTarget(row["target"]!["kcal"]!.GetValue<double>(), row["target"]!["protein_g"]!.GetValue<double>());
            var res = Scaler.Scale(recipe, fx.Data.IngredientsById, target, new ScaleOptions { ForceZeroCarb = row["force_zero_carb"]!.GetValue<bool>() });
            GoldenJson.AssertSame(row["result"], GoldenJson.ToNode(res), $"scale[{recipe.Id}]");
        }
    }
}

public class GoldenPlanTests(GoldenFixture fx) : IClassFixture<GoldenFixture>
{
    public static IEnumerable<object[]> Cases() =>
        Directory.GetFiles(Path.Combine(TestPaths.Golden, "cases"), "*.json").OrderBy(f => f, StringComparer.Ordinal).Select(f => new object[] { Path.GetFileNameWithoutExtension(f) });

    [Theory]
    [MemberData(nameof(Cases))]
    public void Khop_WeekPlan(string caseId)
    {
        var g = GoldenJson.Read($"cases/{caseId}.json");
        var input = g["input"]!;
        var profile = input["profile"].Deserialize<Profile>(JsonOptions.Default)!;
        var prefs = input["preferences"].Deserialize<Preferences>(JsonOptions.Default)!;
        var targets = TargetCalc.Compute(profile);
        GoldenJson.AssertSame(input["targets"], GoldenJson.ToNode(targets), "targets");

        var plan = WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = targets, Prefs = prefs, Data = fx.Data, StartDate = input["start_date"]!.GetValue<string>(), Seed = input["seed"]!.GetValue<long>(),
            Options = new PlanOptions { MealStyle = MealStyle.FullMealOnly },
        });
        GoldenJson.AssertSame(g["plan"], GoldenJson.ToNode(plan), "plan");
    }
}
