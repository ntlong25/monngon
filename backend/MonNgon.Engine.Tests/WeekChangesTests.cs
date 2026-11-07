using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-067 — thay đổi tuần: đổi món, đổi nguyên liệu, ăn ngoài/bỏ bữa, lên lại phần còn lại (US-5.1…5.5).</summary>
public class WeekChangesTests
{

    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";

    private static string Js(object x) => JsonSerializer.Serialize(x, JsonOptions.Default);
    private static T Clone<T>(T x) => JsonSerializer.Deserialize<T>(Js(x!), JsonOptions.Default)!;

    private static TestProfile P(string prefix) => Profiles.Single(p => p.Id.StartsWith(prefix, StringComparison.Ordinal));

    /// <summary>Lập tuần rồi đi qua JSON như máy khách thật (gửi lại đúng thứ đã nhận).</summary>
    private static EditInput Setup(TestProfile p, Action<Preferences>? edit = null, MealStyle style = MealStyle.Auto, long seed = 1)
    {
        var prefs = Clone(p.Preferences);
        edit?.Invoke(prefs);
        var targets = TargetCalc.Compute(p.Profile);
        var plan = WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = targets, Prefs = prefs, Data = Data, StartDate = Start, Seed = seed, Options = new PlanOptions { MealStyle = style },
        });
        return new EditInput { Targets = targets, Prefs = prefs, Data = Data, Plan = Clone(plan) };
    }

    private static EditInput With(EditInput i, WeekPlan plan) => new() { Targets = i.Targets, Prefs = i.Prefs, Data = Data, Plan = Clone(plan), IncludeDessert = i.IncludeDessert };

    private static PlanMeal Meal(WeekPlan plan, string date, string slot) => plan.Days.Single(d => d.Date == date).Meals.Single(m => m.Slot == slot);

    private static IEnumerable<PlanMeal> Planned(WeekPlan plan) => plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned");

    private static Recipe RecipeOf(PlanMeal m) => MamBuilder.Rebuild(m.RecipeId!, Data)?.Composite ?? Data.RecipesById[m.RecipeId!];

    private static HashSet<string> IngredientsOf(Recipe r) => r.Ingredients.Select(i => i.IngredientId).ToHashSet();

    // ------------------------------------------------------------------------------ US-5.1

    [Fact]
    public void Goi_y_doi_mon_2_den_3_mon_giu_ngay_dat_kem_chenh_lech()
    {
        var inp = Setup(P("p01"));
        Assert.Equal("ready", inp.Plan.Status);
        var cur = Meal(inp.Plan, "2026-11-10", "dinner");
        var r = WeekPlanner.SuggestSwaps(inp, "2026-11-10", "dinner");
        Assert.True(r.AnyKeepsDay);
        Assert.InRange(r.Items.Count, 2, 3);
        Assert.Equal(cur.RecipeId, r.CurrentRecipeId);
        Assert.Equal(r.Items.Count, r.Items.Select(i => i.RecipeId).Distinct().Count());
        foreach (var s in r.Items)
        {
            Assert.NotEqual(cur.RecipeId, s.RecipeId);
            Assert.True(s.KeepsDayOk);
            Assert.True(s.DayProteinG >= inp.Targets.ProteinG - 1e-6, $"{s.RecipeId} protein ngày {s.DayProteinG}");
            Assert.InRange(s.DayKcal, inp.Targets.KcalMin - 1e-6, inp.Targets.KcalMax + 1e-6);
            Assert.Equal(s.Macros.ProteinG - cur.Macros.ProteinG, s.DeltaProteinG, 6);
            Assert.Equal(s.Macros.Kcal - cur.Macros.Kcal, s.DeltaKcal, 6);
            Assert.True(r.Recipes.ContainsKey(s.RecipeId));
            Assert.NotEmpty(s.Dishes);
        }
    }

    [Fact]
    public void Doi_mon_chi_doi_dung_bua_do_cac_bua_va_ngay_khac_giu_nguyen_tung_chu_so()
    {
        var inp = Setup(P("p01"));
        var pick = WeekPlanner.SuggestSwaps(inp, "2026-11-11", "lunch").Items[0];
        var after = WeekPlanner.ApplySwap(inp, "2026-11-11", "lunch", pick.RecipeId);

        Assert.Equal(pick.RecipeId, Meal(after, "2026-11-11", "lunch").RecipeId);
        foreach (var d in inp.Plan.Days)
            foreach (var m in d.Meals.Where(m => !(m.Date == "2026-11-11" && m.Slot == "lunch")))
            {
                var m2 = Meal(after, m.Date, m.Slot);
                // BatchGroupId của công thức cũ/mới có thể được nhóm lại; mọi thứ còn lại phải y nguyên.
                m2.BatchGroupId = m.BatchGroupId;
                Assert.Equal(Js(m), Js(m2));
            }
        // Ngày đổi vẫn đạt đúng như gợi ý đã hứa; validator và đi chợ được tính lại.
        var day = after.Days.Single(d => d.Date == "2026-11-11");
        Assert.True(after.Validation.Days.Single(v => v.Date == day.Date).Ok);
        Assert.Equal(pick.DayKcal, day.Totals.Kcal, 3);
        Assert.NotEqual(Js(inp.Plan.Shopping), Js(after.Shopping));
        Assert.Equal(Planned(after).Select(m => m.RecipeId).Distinct().Count(), after.DistinctRecipes);
        // Dishes của bữa mới khớp macro của bữa.
        var nm = Meal(after, "2026-11-11", "lunch");
        Assert.Equal(nm.Macros.Kcal, nm.Dishes!.Sum(x => x.Macros.Kcal), 3);
    }

    [Fact]
    public void Goi_y_khong_bao_gio_vi_pham_rang_buoc_cung_voi_moi_ho_so()
    {
        foreach (var p in Profiles)
        {
            var inp = Setup(p);
            var banned = Filter.BannedIngredients(Data.Ingredients, inp.Prefs);
            var blocked = inp.Prefs.BlockedRecipeIds.ToHashSet();
            var meals = Planned(inp.Plan).Where(m => m.Slot is "lunch" or "dinner" or "breakfast").Take(4).ToList();
            foreach (var m in meals)
            {
                var r = WeekPlanner.SuggestSwaps(inp, m.Date, m.Slot, 5);
                foreach (var s in r.Items)
                {
                    foreach (var rid in s.Dishes.Select(d => d.RecipeId))
                    {
                        Assert.DoesNotContain(rid, blocked);
                        foreach (var li in Data.RecipesById[rid].Ingredients)
                            Assert.False(banned.ContainsKey(li.IngredientId), $"{p.Id}: {rid} chứa {li.IngredientId} bị cấm");
                        var eq = Data.RecipesById[rid].Equipment;
                        Assert.True(eq.All(inp.Prefs.Equipment.Contains), $"{p.Id}: {rid} cần dụng cụ không có");
                    }
                }
            }
        }
    }

    [Fact]
    public void Khong_mon_nao_giu_ngay_dat_thi_noi_ro_va_tra_mon_gan_dat_nhat()
    {
        // Ngày chật: chỉ tiêu cứng ép lên rất cao nên mọi món thay thế đều làm ngày không đạt.
        var inp = Setup(P("p01"));
        var tough = new EditInput
        {
            Targets = new Targets { Mode = inp.Targets.Mode, KcalTarget = inp.Targets.KcalTarget, KcalMin = inp.Targets.KcalMin, KcalMax = inp.Targets.KcalMax, ProteinG = 400 }, Prefs = inp.Prefs, Data = Data, Plan = inp.Plan,
        };
        var r = WeekPlanner.SuggestSwaps(tough, "2026-11-10", "dinner");
        Assert.False(r.AnyKeepsDay);
        Assert.NotEmpty(r.Items);
        Assert.All(r.Items, s => Assert.False(s.KeepsDayOk));
        // gần đạt nhất: đạm ngày không tăng dần theo thứ tự trả về (món đứng đầu thiếu ít nhất)
        Assert.Equal(r.Items.Select(s => s.DayProteinG).OrderByDescending(x => x), r.Items.Select(s => s.DayProteinG));
    }

    [Fact]
    public void Doi_sang_mon_khong_hop_le_bi_tu_choi()
    {
        var inp = Setup(P("p01"), p => p.Exclusions = ["no_fish"]);
        var cur = Meal(inp.Plan, "2026-11-10", "dinner");
        // món có cá bị loại ở bước lọc cứng → không nằm trong ứng viên của bữa
        var fish = Data.Recipes.First(r => r.DishRole == "full_meal" && r.MealTypes.Contains("dinner") && r.Ingredients.Any(i => i.IngredientId.Contains("ca_", StringComparison.Ordinal) && Data.IngredientsById[i.IngredientId].DietTags.Contains("fish")));
        var e = Assert.Throws<EditException>(() => WeekPlanner.ApplySwap(inp, cur.Date, cur.Slot, fish.Id));
        Assert.Equal("recipe_id", e.Field);
        var same = Assert.Throws<EditException>(() => WeekPlanner.ApplySwap(inp, cur.Date, cur.Slot, cur.RecipeId!));
        Assert.Equal("recipe_id", same.Field);
        var none = Assert.Throws<EditException>(() => WeekPlanner.ApplySwap(inp, cur.Date, cur.Slot, "khong_co_mon_nay"));
        Assert.Equal("recipe_id", none.Field);
    }

    [Fact]
    public void Thao_tac_sai_ngay_hoac_bua_tra_loi_co_truong()
    {
        var inp = Setup(P("p01"));
        Assert.Equal("date", Assert.Throws<EditException>(() => WeekPlanner.SuggestSwaps(inp, "2026-12-31", "lunch")).Field);
        Assert.Equal("slot", Assert.Throws<EditException>(() => WeekPlanner.SuggestSwaps(inp, "2026-11-10", "snack_am")).Field);
        Assert.Equal("slot", Assert.Throws<EditException>(() => WeekPlanner.SuggestSwaps(inp, "2026-11-10", "brunch")).Field);
    }

    [Fact]
    public void Tuan_goi_len_voi_so_dong_gram_sai_bi_tu_choi()
    {
        var inp = Setup(P("p01"));
        var bad = Clone(inp.Plan);
        Meal(bad, "2026-11-09", "lunch").Grams.RemoveAt(0);
        var e = Assert.Throws<EditException>(() => WeekPlanner.SuggestSwaps(With(inp, bad), "2026-11-10", "dinner"));
        Assert.StartsWith("plan.days[", e.Field, StringComparison.Ordinal);
    }

    // ------------------------------------------------------------------------------ US-5.2

    private static (PlanMeal Meal, string IngredientId) SwappableLine(EditInput inp)
    {
        foreach (var m in Planned(inp.Plan).Where(m => m.Slot is "lunch" or "dinner" or "breakfast"))
        {
            var r = RecipeOf(m);
            for (var i = 0; i < r.Ingredients.Count; i++)
                if (r.Ingredients[i].SwapGroup is { Length: > 0 } && r.Ingredients[i].Role == "protein" && WeekPlanner.GetIngredientOptions(inp, m.Date, m.Slot, m.Grams[i].IngredientId).Options.Count > 0)
                    return (m, m.Grams[i].IngredientId);
        }
        throw new InvalidOperationException("không có nguyên liệu đạm thay được");
    }

    [Fact]
    public void Doi_nguyen_lieu_chi_hien_cung_nhom_thay_the_giu_protein_trong_5_phan_tram()
    {
        var inp = Setup(P("p01"));
        var (m, ing) = SwappableLine(inp);
        var o = WeekPlanner.GetIngredientOptions(inp, m.Date, m.Slot, ing);
        Assert.NotEmpty(o.Options);
        var group = o.SwapGroup;
        foreach (var opt in o.Options)
        {
            Assert.NotEqual(ing, opt.IngredientId);
            Assert.Contains(Data.Recipes, r => r.Ingredients.Any(i => i.IngredientId == opt.IngredientId && i.SwapGroup == group));
            Assert.True(Math.Abs(opt.DeltaProteinG) <= 0.05 * m.Macros.ProteinG + 1e-6, $"{opt.IngredientId} lệch protein {opt.DeltaProteinG}");
        }
        var pick = o.Options[0];
        var after = WeekPlanner.SwapIngredient(inp, m.Date, m.Slot, ing, pick.IngredientId);
        var nm = Meal(after, m.Date, m.Slot);
        Assert.Contains(nm.Grams, g => g.IngredientId == pick.IngredientId);
        Assert.Contains(nm.Substitutions, s => s.To == pick.IngredientId);
        Assert.Equal(m.RecipeId, nm.RecipeId);
        Assert.True(Math.Abs(nm.Macros.ProteinG - m.Macros.ProteinG) <= 0.05 * m.Macros.ProteinG + 1e-6);
        Assert.Equal(pick.Grams, nm.Grams.First(g => g.IngredientId == pick.IngredientId).Grams, 6);
        // chỉ bữa đó đổi; đi chợ tính lại
        foreach (var other in inp.Plan.Days.SelectMany(d => d.Meals).Where(x => !(x.Date == m.Date && x.Slot == m.Slot)))
            Assert.Equal(Js(other), Js(Meal(after, other.Date, other.Slot)));
        Assert.NotEqual(Js(inp.Plan.Shopping), Js(after.Shopping));
        Assert.Contains(after.Shopping.Items, i => i.IngredientId == pick.IngredientId);
    }

    [Fact]
    public void Doi_nguyen_lieu_khong_bao_gio_de_nghi_nguyen_lieu_bi_cam()
    {
        var inp = Setup(P("p01"), p => { p.Exclusions = ["no_pork", "no_fish"]; p.DislikedIngredientIds = ["dau_phu"]; });
        var banned = Filter.BannedIngredients(Data.Ingredients, inp.Prefs);
        var count = 0;
        foreach (var m in Planned(inp.Plan))
        {
            var r = RecipeOf(m);
            for (var i = 0; i < r.Ingredients.Count; i++)
            {
                if (string.IsNullOrEmpty(r.Ingredients[i].SwapGroup)) continue;
                var o = WeekPlanner.GetIngredientOptions(inp, m.Date, m.Slot, m.Grams[i].IngredientId);
                foreach (var opt in o.Options) Assert.False(banned.ContainsKey(opt.IngredientId), $"{opt.IngredientId} bị cấm");
                count++;
            }
            if (count > 40) break;
        }
        Assert.True(count > 0);
    }

    [Fact]
    public void Doi_nguyen_lieu_khong_cung_nhom_hoac_khong_co_nhom_bi_tu_choi()
    {
        var inp = Setup(P("p01"));
        var (m, ing) = SwappableLine(inp);
        Assert.Equal("to_ingredient_id", Assert.Throws<EditException>(() => WeekPlanner.SwapIngredient(inp, m.Date, m.Slot, ing, "dau_an")).Field);
        Assert.Equal("ingredient_id", Assert.Throws<EditException>(() => WeekPlanner.GetIngredientOptions(inp, m.Date, m.Slot, "khong_co")).Field);
    }

    // ------------------------------------------------------------------------------ US-5.3

    [Fact]
    public void An_ngoai_mien_kiem_ngay_rut_khoi_di_cho_khac_bua_giu_nguyen_va_hoan_tac_ve_dung_ban_dau()
    {
        var inp = Setup(P("p01"));
        var date = "2026-11-12";
        var before = Meal(inp.Plan, date, "dinner");
        var after = WeekPlanner.MarkOut(inp, date, "dinner", "eat_out");

        Assert.Equal("eaten_out", Meal(after, date, "dinner").Status);
        var v = after.Validation.Days.Single(d => d.Date == date);
        Assert.True(v.Exempt);
        Assert.True(v.Ok);
        // các bữa khác trong ngày giữ nguyên
        foreach (var m in inp.Plan.Days.Single(d => d.Date == date).Meals.Where(m => m.Slot != "dinner"))
            Assert.Equal(Js(m), Js(Meal(after, date, m.Slot)));
        // tổng ngày không còn tính bữa ngoài; chi phí và danh sách đi chợ giảm
        var dayAfter = after.Days.Single(d => d.Date == date);
        Assert.Equal(inp.Plan.Days.Single(d => d.Date == date).Totals.Kcal - before.Macros.Kcal, dayAfter.Totals.Kcal, 3);
        Assert.True(after.Shopping.WeekFoodCost < inp.Plan.Shopping.WeekFoodCost);
        Assert.DoesNotContain(after.Shopping.Items, i => i.NeedG > 0 && inp.Plan.Shopping.Items.All(o => o.IngredientId != i.IngredientId));

        // hoàn tác: đúng tuần ban đầu
        var undo = WeekPlanner.MarkOut(With(inp, after), date, "dinner", "undo");
        Assert.Equal(Js(inp.Plan), Js(undo));
    }

    [Fact]
    public void Bo_bua_giong_an_ngoai_va_chuyen_qua_lai_duoc()
    {
        var inp = Setup(P("p01"));
        var skipped = WeekPlanner.MarkOut(inp, "2026-11-12", "breakfast", "skip");
        Assert.Equal("skipped", Meal(skipped, "2026-11-12", "breakfast").Status);
        Assert.True(skipped.Validation.Days.Single(d => d.Date == "2026-11-12").Exempt);
        var out2 = WeekPlanner.MarkOut(With(inp, skipped), "2026-11-12", "breakfast", "eat_out");
        Assert.Equal("eaten_out", Meal(out2, "2026-11-12", "breakfast").Status);
        Assert.Equal("mode", Assert.Throws<EditException>(() => WeekPlanner.MarkOut(inp, "2026-11-12", "breakfast", "abc")).Field);
        Assert.Equal("slot", Assert.Throws<EditException>(() => WeekPlanner.MarkOut(inp, "2026-11-12", "breakfast", "undo")).Field);
    }

    [Fact]
    public void Bua_da_danh_dau_khong_doi_mon_duoc_va_ngay_khong_tinh_thieu()
    {
        var inp = Setup(P("p01"));
        var after = WeekPlanner.MarkOut(inp, "2026-11-12", "lunch", "eat_out");
        Assert.Throws<EditException>(() => WeekPlanner.SuggestSwaps(With(inp, after), "2026-11-12", "lunch"));
        Assert.DoesNotContain(after.Validation.Shortfalls, s => s.Date == "2026-11-12");
        Assert.Equal(inp.Plan.Validation.Days.Count, after.Validation.Days.Count);
    }

    // ------------------------------------------------------------------------------ US-5.5

    [Fact]
    public void Len_lai_phan_con_lai_giu_nguyen_ngay_qua_va_hom_nay_va_tao_lai_cac_ngay_sau()
    {
        var inp = Setup(P("p01"));
        var today = "2026-11-11";
        var after = WeekPlanner.RegenerateRest(inp, today, 7);
        Assert.Equal(inp.Plan.Days.Count, after.Days.Count);
        Assert.Equal(inp.Plan.StartDate, after.StartDate);
        for (var i = 0; i < 3; i++) Assert.Equal(Js(inp.Plan.Days[i]), Js(after.Days[i]));
        Assert.Equal(inp.Plan.Days.Select(d => d.Date), after.Days.Select(d => d.Date));
        Assert.NotEqual(Js(inp.Plan.Days.Skip(3).ToList()), Js(after.Days.Skip(3).ToList()));
        // validator và đi chợ tính lại cho cả tuần (gồm ngày giữ)
        Assert.Equal(7, after.Validation.Days.Count);
        Assert.True(after.Shopping.WeekFoodCost > 0);
        Assert.Equal("ready", after.Status);
        // chạy lại với cùng seed thì cùng kết quả
        Assert.Equal(Js(after), Js(WeekPlanner.RegenerateRest(inp, today, 7)));
    }

    [Fact]
    public void Len_lai_ton_trong_mon_bi_chan_o_cac_ngay_sau_nhung_giu_bua_hom_nay()
    {
        var inp = Setup(P("p01"));
        var today = "2026-11-10";
        // chặn một món chính đang dùng ở ngày sau và một món đang dùng ở hôm nay
        var later = inp.Plan.Days.Skip(2).SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Slot == "dinner").First();
        var todays = Meal(inp.Plan, today, "dinner");
        var blockIds = new List<string>();
        foreach (var m in new[] { later, todays })
        {
            if (m.RecipeId!.StartsWith("mam:", StringComparison.Ordinal)) blockIds.AddRange(m.Dishes!.Where(d => d.Role == "main").Select(d => d.RecipeId!));
            else blockIds.Add(m.RecipeId!);
        }
        inp.Prefs.BlockedRecipeIds = [.. blockIds];
        var after = WeekPlanner.RegenerateRest(inp, today, null);

        Assert.Equal(Js(Meal(inp.Plan, today, "dinner")), Js(Meal(after, today, "dinner")));
        foreach (var m in after.Days.Skip(2).SelectMany(d => d.Meals).Where(m => m.Status == "planned"))
        {
            var ids = m.Dishes is null ? [m.RecipeId!] : m.Dishes.Select(d => d.RecipeId).OfType<string>().Append(m.RecipeId!).ToList();
            foreach (var b in blockIds) Assert.DoesNotContain(b, ids);
        }
    }

    [Fact]
    public void Len_lai_van_thay_duoc_mam_cu_khi_mon_cua_no_vua_bi_chan()
    {
        var inp = Setup(P("p01"));
        var mamMeal = inp.Plan.Days.Take(2).SelectMany(d => d.Meals).First(m => m.RecipeId?.StartsWith("mam:", StringComparison.Ordinal) == true);
        inp.Prefs.BlockedRecipeIds = [.. inp.Prefs.BlockedRecipeIds, .. mamMeal.Dishes!.Where(d => d.Role is "main" or "soup").Select(d => d.RecipeId!)];
        var after = WeekPlanner.RegenerateRest(inp, mamMeal.Date, null);
        var kept = Meal(after, mamMeal.Date, mamMeal.Slot);
        Assert.Equal(mamMeal.RecipeId, kept.RecipeId);
        Assert.Contains(after.MamRecipes, r => r.Id == mamMeal.RecipeId);
        // và đổi nguyên liệu/ăn ngoài trên chính tuần này vẫn chạy được với bữa mâm cũ
        Assert.Equal("eaten_out", Meal(WeekPlanner.MarkOut(With(inp, after), mamMeal.Date, mamMeal.Slot, "eat_out"), mamMeal.Date, mamMeal.Slot).Status);
    }

    [Fact]
    public void Len_lai_giu_dau_an_ngoai_da_danh_dau_o_cac_ngay_sau()
    {
        var inp = Setup(P("p01"));
        var marked = WeekPlanner.MarkOut(inp, "2026-11-14", "dinner", "eat_out");
        var after = WeekPlanner.RegenerateRest(With(inp, marked), "2026-11-10", 5);
        Assert.Equal("eaten_out", Meal(after, "2026-11-14", "dinner").Status);
        Assert.True(after.Validation.Days.Single(d => d.Date == "2026-11-14").Exempt);
    }

    [Fact]
    public void Len_lai_khi_het_ngay_hoac_sai_dinh_dang_bao_loi()
    {
        var inp = Setup(P("p01"));
        Assert.Equal("today", Assert.Throws<EditException>(() => WeekPlanner.RegenerateRest(inp, "2026-11-15", 1)).Field);
        Assert.Equal("today", Assert.Throws<EditException>(() => WeekPlanner.RegenerateRest(inp, "hôm nay", 1)).Field);
        // trước ngày bắt đầu: lập lại cả tuần
        var all = WeekPlanner.RegenerateRest(inp, "2026-11-01", 3);
        Assert.Equal(7, all.Days.Count);
    }

    [Fact]
    public void Che_do_tuong_thich_full_meal_only_cung_chinh_duoc()
    {
        var inp = Setup(P("p01"), style: MealStyle.FullMealOnly);
        Assert.Null(inp.Plan.MealStyle);
        var r = WeekPlanner.SuggestSwaps(inp, "2026-11-10", "dinner");
        Assert.NotEmpty(r.Items);
        var after = WeekPlanner.ApplySwap(inp, "2026-11-10", "dinner", r.Items[0].RecipeId);
        Assert.Null(after.MealStyle);
        Assert.Null(Meal(after, "2026-11-10", "dinner").Dishes);
        var out2 = WeekPlanner.MarkOut(inp, "2026-11-10", "dinner", "eat_out");
        Assert.True(out2.Validation.Days.Single(d => d.Date == "2026-11-10").Exempt);
    }
}
