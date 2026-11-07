using System.Globalization;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Api;

/// <summary>Kiểm đầu vào (tương đương zod ở TS). Lỗi trả về dạng đường-dẫn-trường → danh sách thông điệp.</summary>
public sealed class Errors
{
    private readonly Dictionary<string, List<string>> _d = new();
    public bool Any => _d.Count > 0;
    public void Add(string field, string msg)
    {
        if (!_d.TryGetValue(field, out var l)) _d[field] = l = [];
        l.Add(msg);
    }
    public Dictionary<string, string[]> ToDictionary() => _d.ToDictionary(kv => kv.Key, kv => kv.Value.ToArray());
}

public static class Validation
{
    private static readonly HashSet<string> CookingEquipment = ["bep", "noi_com_dien", "lo_vi_song", "noi_chien_khong_dau", "lo_nuong", "noi_ap_suat"];

    private static void Range(Errors e, string f, double v, double min, double max)
    {
        if (!double.IsFinite(v) || v < min || v > max)
            e.Add(f, $"phải trong khoảng {min.ToString(CultureInfo.InvariantCulture)}–{max.ToString(CultureInfo.InvariantCulture)}");
    }

    private static void OneOf(Errors e, string f, string v, string[] allowed)
    {
        if (!allowed.Contains(v)) e.Add(f, $"giá trị \"{v}\" không hợp lệ (một trong: {string.Join(", ", allowed)})");
    }

    private static void AllOf(Errors e, string f, IEnumerable<string>? vs, string[] allowed)
    {
        if (vs is null) { e.Add(f, "bắt buộc"); return; }
        var i = 0;
        foreach (var v in vs) { OneOf(e, $"{f}[{i}]", v, allowed); i++; }
    }

    public static void Profile(Errors e, Profile? p, string prefix = "profile")
    {
        if (p is null) { e.Add(prefix, "bắt buộc"); return; }
        OneOf(e, $"{prefix}.goal", p.Goal, Enums.Goals);
        OneOf(e, $"{prefix}.sex", p.Sex, Enums.Sexes);
        Range(e, $"{prefix}.age", p.Age, 14, 90);
        Range(e, $"{prefix}.height_cm", p.HeightCm, 120, 220);
        Range(e, $"{prefix}.weight_kg", p.WeightKg, 30, 250);
        OneOf(e, $"{prefix}.activity", p.Activity, Enums.Activities);
        OneOf(e, $"{prefix}.target_mode", p.TargetMode, ["formula", "manual"]);
        if (p.TargetMode == "manual")
        {
            if (p.ManualKcal is not > 0) e.Add($"{prefix}.manual_kcal", "cần > 0 khi target_mode = manual");
            if (p.ManualProteinG is not > 0) e.Add($"{prefix}.manual_protein_g", "cần > 0 khi target_mode = manual");
        }
    }

    public static void Slots(Errors e, SlotsConfig? s, string prefix = "slots")
    {
        if (s is null) { e.Add(prefix, "bắt buộc"); return; }
        foreach (var slot in Enums.Slots) OneOf(e, $"{prefix}.{slot}", s.Mode(slot), Enums.SlotModes);
        OneOf(e, $"{prefix}.lunch_style", s.LunchStyle, ["hot", "packed"]);
        OneOf(e, $"{prefix}.snack_pm_style", s.SnackPmStyle, ["sweet", "savory"]);
        if (!new[] { "breakfast", "lunch", "dinner" }.Any(x => s.Mode(x) == "on"))
            e.Add($"{prefix}.breakfast", "cần ít nhất 1 bữa chính (sáng/trưa/tối) ở chế độ \"on\" (Lên thực đơn)");
    }

    public static void Preferences(Errors e, Preferences? p, Dataset data)
    {
        if (p is null) { e.Add("preferences", "bắt buộc"); return; }
        if (!data.StoresById.ContainsKey(p.StoreId)) e.Add("preferences.store_id", $"cửa hàng \"{p.StoreId}\" không tồn tại");
        if (!double.IsFinite(p.WeeklyBudgetVnd) || p.WeeklyBudgetVnd < 0) e.Add("preferences.weekly_budget_vnd", "không được âm");
        Range(e, "preferences.adults", p.Adults, 1, 6);
        Range(e, "preferences.children", p.Children, 0, 4);
        Slots(e, p.Slots, "preferences.slots");
        OneOf(e, "preferences.diet", p.Diet, Enums.Diets);
        OneOf(e, "preferences.rice_habit", p.RiceHabit, Enums.RiceHabits);
        AllOf(e, "preferences.exclusions", p.Exclusions, Enums.Exclusions);
        AllOf(e, "preferences.equipment", p.Equipment, Enums.Equipment);
        // D-QA-05 / L-02: phải có ít nhất một thiết bị nấu (máy xay không tính), khớp với app (US-1.5 AC3).
        if (p.Equipment is not null && !p.Equipment.Any(CookingEquipment.Contains))
            e.Add("preferences.equipment", "cần ít nhất 1 thiết bị nấu (bếp, nồi cơm điện, lò vi sóng, nồi chiên không dầu, lò nướng hoặc nồi áp suất)");
        // D-ONB-03: chỉ nhận 4 xu hướng chính thức; thẻ nội bộ (giau_dam, omega3, chay, low_carb) bị từ chối.
        AllOf(e, "preferences.health_leanings", p.HealthLeanings, V1Endpoints.HealthWhitelist.ToArray());
    }

    public static void State(Errors e, PlanStateDto? s, Dataset data)
    {
        if (s is null) { e.Add("state", "bắt buộc"); return; }
        Profile(e, s.Profile, "state.profile");
        if (s.Preferences is null) e.Add("state.preferences", "bắt buộc");
        else
        {
            var inner = new Errors();
            Preferences(inner, s.Preferences, data);
            foreach (var kv in inner.ToDictionary())
                foreach (var m in kv.Value) e.Add(kv.Key.Replace("preferences", "state.preferences", StringComparison.Ordinal), m);
        }
        if (s.Plan is null) e.Add("state.plan", "bắt buộc");
    }

    public static void MealStyle(Errors e, string? s)
    {
        if (!MonNgon.Engine.MealStyles.Wire.Contains(s ?? ""))
            e.Add("meal_style", $"giá trị \"{s}\" không hợp lệ (một trong: {string.Join(", ", MonNgon.Engine.MealStyles.Wire)})");
    }

    public static void StartDate(Errors e, string? s)
    {
        if (!DateOnly.TryParseExact(s ?? "", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _))
            e.Add("start_date", "phải có dạng YYYY-MM-DD");
    }
}
