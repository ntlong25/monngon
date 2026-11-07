using System.Security.Cryptography;
using System.Text;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

/// <summary>Phiên bản dữ liệu = SHA-256 của (tên + NUL + nội dung + NUL) các file data/*.json theo thứ tự tên (cùng cách với golden/).</summary>
public static class DataVersion
{
    public static string Compute(string dir)
    {
        using var sha = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        var names = Directory.GetFiles(dir, "*.json").Select(f => Path.GetFileName(f)).OrderBy(n => n, StringComparer.Ordinal);
        foreach (var name in names)
            sha.AppendData(Encoding.UTF8.GetBytes(name + "\0" + File.ReadAllText(Path.Combine(dir, name), Encoding.UTF8) + "\0"));
        return Convert.ToHexString(sha.GetHashAndReset()).ToLowerInvariant();
    }
}

/// <summary>Bỏ dấu tiếng Việt để tìm kiếm không dấu ("rau muong" tìm được "Rau muống").</summary>
public static class TextFold
{
    private const string From = "àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ";
    private const string To = "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd";

    public static string Fold(string s)
    {
        var sb = new StringBuilder(s.Length);
        foreach (var c0 in s)
        {
            var c = char.ToLowerInvariant(c0);
            var i = From.IndexOf(c);
            sb.Append(i >= 0 ? To[i] : c);
        }
        return sb.ToString();
    }
}

public sealed record BudgetTier(string Key, double FromVnd, double ToVnd);

public sealed record BudgetRange(double MinVnd, double MaxVnd, double StepVnd, double EstimateVnd, IReadOnlyList<BudgetTier> Tiers, string Basis);

/// <summary>
/// Khoảng ngân sách tuần gợi ý (D-BUD-01). Chi phí là "chi phí món ăn theo gram dùng" (như week_food_cost), không phải tiền trả tại quầy.
/// Mỗi slot lên thực đơn: lấy các ứng viên hợp lệ theo kiêng/ghét/dụng cụ (trọn suất + mâm ghép), scale theo chỉ tiêu slot, cộng phần người khác
/// (khẩu phần chuẩn × hệ số) và tráng miệng trung vị (bữa trưa/tối).
/// min = phân vị 20% từng slot × 7 × 1,10 làm tròn lên; max = max(ước tính × 2,5; min + 500.000) làm tròn lên; bước 50.000 ₫.
/// Ước tính: PM đề xuất trung vị chi phí các ứng viên, nhưng đo thực tế engine chọn món lệch khỏi trung vị (điểm phù hợp chỉ tiêu ưu tiên món đậu/chay rẻ)
/// nên trung vị lệch 30–80% ở nhiều hồ sơ. Vì vậy ước tính = chi phí món ăn của tuần engine thật sự lập (ngân sách không giới hạn, seed 1);
/// nếu engine không lập được thì dùng trung vị.
/// </summary>
public static class BudgetEstimator
{
    public const double Step = 50_000;
    public const double SafetyMargin = 1.10;
    public const double MaxFactor = 2.5;
    public const double MaxMinGap = 500_000;
    public const string Basis = "week_food_cost";
    /// <summary>Ngân sách "không giới hạn" dùng để mô phỏng tuần điển hình (đủ lớn để không kích hoạt sửa ngân sách).</summary>
    public const double SimBudgetVnd = 10_000_000;

    private static double Up(double x) => Math.Ceiling(x / Step - 1e-9) * Step;
    private static double Nearest(double x) => Js.Round(x / Step) * Step;

    /// <summary>Chi phí món ăn của tuần do engine lập với ngân sách không giới hạn; null nếu không lập được.</summary>
    private static double? SimulatedWeekCost(Dataset data, Targets targets, Preferences prefs)
    {
        try
        {
            var copy = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(prefs, JsonOptions.Default), JsonOptions.Default)!;
            copy.WeeklyBudgetVnd = SimBudgetVnd;
            var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = targets, Prefs = copy, Data = data, StartDate = "2026-01-05", Seed = 1 });
            return plan.Shopping.WeekFoodCost > 0 ? plan.Shopping.WeekFoodCost : null;
        }
        catch (NoMainMealException) { throw; }
        catch (Exception) { return null; }
    }

    public static BudgetRange Compute(Dataset data, Targets targets, Preferences prefs)
    {
        var slots = MealSlots.Allocate(targets, prefs.Slots).Where(s => s.Planned).ToList();
        var filtered = Filter.FilterRecipes(data.Recipes, data.IngredientsById, data.Ingredients, prefs);
        var others = Shopping.OtherEatersFactor(new Household(prefs.Adults, prefs.Children));
        double StdCost(Recipe r) => Shopping.RecipeServingCostVnd(r, data, prefs.StoreId);

        var infos = MamBuilder.Build(filtered.Valid.Select(v => v.Recipe).ToList(), StdCost, data.IngredientsById, prefs, 3);
        var source = filtered.Valid.Where(v => v.Recipe.DishRole == "full_meal").Concat(infos.Select(i => new ValidRecipe(i.Composite, false))).ToList();

        var dessertCosts = filtered.Valid.Select(v => v.Recipe).Where(r => r.DishRole == "dessert")
            .Where(r => !prefs.LowCarb || r.LowCarbOk).Select(r => StdCost(r) * (1 + others)).OrderBy(c => c).ToList();
        var dessert = dessertCosts.Count == 0 ? 0 : dessertCosts[dessertCosts.Count / 2];

        double med = 0, p20 = 0;
        foreach (var slot in slots)
        {
            var cands = Filter.RecipesForSlot(source, slot.Slot, prefs.Slots, prefs.LowCarb);
            if (cands.Count == 0) continue;
            var costs = new List<double>(cands.Count);
            foreach (var c in cands)
            {
                var sc = Scaler.Scale(c.Recipe, data.IngredientsById, new ScaleTarget(slot.Kcal, slot.ProteinG), new ScaleOptions { ForceZeroCarb = c.ForceZeroCarb });
                var own = Shopping.ServingCostVnd(sc.Grams, data, prefs.StoreId);
                var rest = Shopping.ServingCostVnd(c.Recipe.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)), data, prefs.StoreId);
                costs.Add(own + others * rest);
            }
            costs.Sort();
            var extra = slot.Slot is "lunch" or "dinner" ? dessert : 0;
            med += costs[costs.Count / 2] + extra;
            p20 += costs[(int)Math.Floor(0.2 * (costs.Count - 1))] + extra;
        }

        var est = SimulatedWeekCost(data, targets, prefs) ?? med * 7;
        var min = Math.Max(Step, Up(p20 * 7 * SafetyMargin));
        var max = Up(Math.Max(est * MaxFactor, min + MaxMinGap));
        var t1 = Math.Min(max, Math.Max(min, Nearest(est * 0.9)));
        var t2 = Math.Min(max, Math.Max(t1, Nearest(est * 1.4)));
        return new BudgetRange(min, max, Step, Js.Round(est / 1000) * 1000, [
            new BudgetTier("economy", min, t1),
            new BudgetTier("moderate", t1, t2),
            new BudgetTier("comfortable", t2, max),
        ], Basis);
    }
}
