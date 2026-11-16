using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-116 / D-SHP-06..08: nhóm mua (Theo tuần / Theo ngày) suy từ storage.json, đợt mua theo ngày, tổng tiền.</summary>
public class ShoppingTripsTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));

    /// <summary>Hai dòng cũ đã bỏ (cơm quy ra gạo, không mua riêng) — bảng của Research vẫn còn nhưng không nằm trong danh sách đi chợ.</summary>
    private static readonly string[] Deprecated = ["com_trang", "gao_lut_nau_chin"];

    private static List<JsonElement> ExpectedTable() =>
        JsonDocument.Parse(File.ReadAllText(Path.Combine(TestPaths.Root, "docs", "research", "ingredient-storage-groups.json"))).RootElement.EnumerateArray().ToList();

    private static ShoppingMeal Meal(int day, params (string Id, double G)[] lines) =>
        new() { Day = day, Ingredients = lines.Select(l => new ShoppingIngredient(l.Id, l.G, l.G)).ToList() };

    private static ShoppingList Build(params ShoppingMeal[] meals) => BuildAt("cho_khac", meals);

    private static ShoppingList BuildAt(string storeId, params ShoppingMeal[] meals) =>
        Shopping.BuildShoppingList(meals, new Household(1, 0), Data, storeId, [], displayQty: true);

    [Fact]
    public void Phan_loai_khop_bang_cua_Research_cho_moi_nguyen_lieu()
    {
        var rows = ExpectedTable().Where(r => !Deprecated.Contains(r.GetProperty("ingredient_id").GetString())).ToList();
        Assert.Equal(67, rows.Count);
        var bad = new List<string>();
        foreach (var r in rows)
        {
            var id = r.GetProperty("ingredient_id").GetString()!;
            var want = r.GetProperty("buy_group").GetString() == "buy_by_day" ? BuyMode.Day : BuyMode.Week;
            var got = ShoppingGroups.Classify(Data, id).Group;
            if (got != want) bad.Add($"{id}: cần {want}, có {got}");
        }
        Assert.Empty(bad);
        Assert.Equal(33, rows.Count(r => r.GetProperty("buy_group").GetString() == "buy_by_day"));
        Assert.Equal(34, rows.Count(r => r.GetProperty("buy_group").GetString() == "stock_buy_by_week"));
        // Không có nhóm "unclassified": mọi nguyên liệu trong dữ liệu đều có nhóm.
        foreach (var ing in Data.Ingredients) Assert.NotNull(ShoppingGroups.Classify(Data, ing.Id));
    }

    [Fact]
    public void Thit_ca_tuoi_la_theo_ngay_bat_ke_so_ngay_va_cong_tac_cap_dong_chi_ap_dung_cho_cap_dong_duoc()
    {
        foreach (var ing in Data.Ingredients.Where(i => i.Aisle is "thit" or "ca_hai_san"))
        {
            var b = ShoppingGroups.Classify(Data, ing.Id);
            Assert.Equal(BuyMode.Day, b.Group);
            Assert.Equal(Data.StorageByIngredient[ing.Id].Freezable == true, b.FreezableMeat);
        }
        // thịt heo đùi để ngăn mát 7 ngày vẫn là Theo ngày (quy tắc thịt cá đứng trước quy tắc số ngày)
        Assert.Equal(BuyMode.Day, ShoppingGroups.Classify(Data, "thit_heo_nac_dui").Group);
        // trứng 21 ngày → Theo tuần; không phải thịt cá nên không có công tắc cấp đông
        var egg = ShoppingGroups.Classify(Data, "trung_ga");
        Assert.Equal(BuyMode.Week, egg.Group);
        Assert.False(egg.FreezableMeat);
        // đậu phụ rời 1 ngày → Theo ngày, không phải thịt cá
        var tofu = ShoppingGroups.Classify(Data, "dau_phu");
        Assert.Equal((BuyMode.Day, 1, false), (tofu.Group, tofu.FreshDays ?? -1, tofu.FreezableMeat));
    }

    [Fact]
    public void Chua_co_nguon_xep_theo_tuan_kem_ghi_chu_khong_doan_so_ngay()
    {
        var none = Data.Storage.Where(s => s.Status == "chua_co_nguon").ToList();
        Assert.NotEmpty(none);
        foreach (var s in none)
        {
            var b = ShoppingGroups.Classify(Data, s.IngredientId);
            Assert.Equal(BuyMode.Week, b.Group);
            Assert.True(b.NoShelfInfo);
            Assert.Null(b.FreshDays);
        }
        Assert.False(ShoppingGroups.Classify(Data, "ca_chua").NoShelfInfo);
    }

    [Fact]
    public void Nhan_dung_trong_n_ngay_lay_can_duoi_ngan_mat()
    {
        Assert.Equal(3, ShoppingGroups.Classify(Data, "sup_lo_xanh").FreshDays);
        Assert.Equal(21, ShoppingGroups.Classify(Data, "trung_ga").FreshDays);
        Assert.Equal(3, ShoppingGroups.Classify(Data, "toi").FreshDays); // ngăn mát 3 ngày; để ngoài 15 ngày là số khác
        Assert.Equal(15, ShoppingGroups.Classify(Data, "khoai_lang").FreshDays); // không có ngăn mát → số ngày để ngoài
    }

    [Fact]
    public void Rau_3_ngay_dung_ngay_1_va_ngay_3_thi_mua_1_lan_ngay_1()
    {
        var list = Build(Meal(0, ("sup_lo_xanh", 100)), Meal(2, ("sup_lo_xanh", 150)));
        var trip = Assert.Single(list.Trips!);
        Assert.Equal(0, trip.DayIndex);
        var it = Assert.Single(trip.Items);
        Assert.Equal(250 / Data.IngredientsById["sup_lo_xanh"].EdiblePortion, it.NeedG, 6);
    }

    [Fact]
    public void Rau_3_ngay_dung_ngay_1_va_ngay_4_thi_mua_2_lan()
    {
        var list = Build(Meal(0, ("sup_lo_xanh", 100)), Meal(3, ("sup_lo_xanh", 150)));
        Assert.Equal([0, 3], list.Trips!.Select(t => t.DayIndex));
    }

    [Fact]
    public void Thit_1_den_2_ngay_dung_ngay_1_va_ngay_4_thi_2_lan()
    {
        var list = Build(Meal(0, ("uc_ga_khong_da", 150)), Meal(3, ("uc_ga_khong_da", 150)));
        Assert.Equal([0, 3], list.Trips!.Select(t => t.DayIndex));
        // thịt 1 ngày dùng liền hai ngày vẫn phải mua riêng (cận dưới 1 ngày)
        var list2 = Build(Meal(0, ("uc_ga_khong_da", 150)), Meal(1, ("uc_ga_khong_da", 150)));
        Assert.Equal([0, 1], list2.Trips!.Select(t => t.DayIndex));
    }

    [Fact]
    public void Chuoi_mua_som_dem_tu_ngay_mua_va_dot_sau_bat_dau_lai_o_ngay_dung_ke_tiep()
    {
        // 3 ngày tươi: dùng ngày 0, 2, 3, 6 → đợt ngày 0 (0,2), đợt ngày 3 (3), đợt ngày 6 (6)
        var list = Build(Meal(0, ("sup_lo_xanh", 50)), Meal(2, ("sup_lo_xanh", 50)), Meal(3, ("sup_lo_xanh", 50)), Meal(6, ("sup_lo_xanh", 50)));
        Assert.Equal([0, 3, 6], list.Trips!.Select(t => t.DayIndex));
        var grams = list.Trips!.SelectMany(t => t.Items).Select(i => i.NeedG).ToList();
        Assert.Equal(3, grams.Count);
        Assert.Equal(list.Items.Single().NeedG, grams.Sum(), 6);
    }

    [Fact]
    public void Chi_nhom_theo_ngay_vao_dot_mua_con_nhom_theo_tuan_thi_khong()
    {
        var list = Build(Meal(0, ("uc_ga_khong_da", 150), ("gao_te", 100), ("trung_ga", 100)), Meal(1, ("trung_ga", 100)));
        var ids = list.Trips!.SelectMany(t => t.Items).Select(i => i.IngredientId).ToHashSet();
        Assert.Equal(["uc_ga_khong_da"], ids);
        Assert.Equal("week", list.Items.Single(i => i.IngredientId == "trung_ga").BuyGroup);
        Assert.Equal("day", list.Items.Single(i => i.IngredientId == "uc_ga_khong_da").BuyGroup);
    }

    [Fact]
    public void O_sieu_thi_goi_lam_tron_rieng_tung_dot_nen_mua_hai_dot_dat_hon_mot_lan()
    {
        // BHX có giá gói 200 g cho thịt heo xay: 2 bữa × 100 g mua gộp một lần vừa 1 gói, mua 2 đợt (thịt 1 ngày) phải 2 gói
        var list = BuildAt("bach_hoa_xanh", Meal(0, ("thit_heo_xay_nac", 100)), Meal(3, ("thit_heo_xay_nac", 100)));
        var item = list.Items.Single();
        Assert.Equal(1, item.Packs);
        var lines = list.Trips!.SelectMany(t => t.Items).ToList();
        Assert.All(lines, i => { Assert.Equal(1, i.Packs); Assert.Null(i.SoldByWeight); });
        Assert.Equal(2, lines.Count);
        var totals = ShoppingGroups.TillTotals(list, new HashSet<string>(), freezeMeat: false);
        Assert.Equal(0, totals.Week);
        Assert.True(totals.Total > list.TillCost);
    }

    [Fact]
    public void O_cho_thit_ca_rau_qua_mua_theo_can_lam_tron_len_100_g_toi_thieu_100_g()
    {
        var chicken = Data.IngredientsById["uc_ga_khong_da"];
        var price = Data.PricesByIngredient["uc_ga_khong_da"]["cho_khac"];
        Assert.Equal("cho_khac", price.StoreId);
        // cần 25 g (sau phần ăn được) → 100 g, giá = 100 × đơn giá/g
        var list = Build(Meal(0, ("uc_ga_khong_da", 25 * chicken.EdiblePortion)));
        var line = Assert.Single(Assert.Single(list.Trips!).Items);
        Assert.True(line.SoldByWeight);
        Assert.Equal(25, line.NeedG, 6);
        Assert.Equal(100, line.PackG);
        Assert.Equal(1, line.Packs);
        Assert.Equal("100 g", line.DisplayQty);
        Assert.Equal(100 * price.PriceVnd / price.PackG, line.TillCostVnd, 6);
        Assert.Equal(75, line.LeftoverG, 6);
        // rau 230 g → 300 g
        var tomato = Data.IngredientsById["ca_chua"];
        var veg = Build(Meal(0, ("ca_chua", 230 * tomato.EdiblePortion)));
        var vl = Assert.Single(Assert.Single(veg.Trips!).Items);
        Assert.Equal((3, "300 g"), (vl.Packs, vl.DisplayQty));
        var vp = Data.PricesByIngredient["ca_chua"]["cho_khac"];
        Assert.Equal(300 * vp.PriceVnd / vp.PackG, vl.TillCostVnd, 6);
        // đúng 300 g không bị làm tròn lên thành 400 g
        var exact = Build(Meal(0, ("ca_chua", 300 * tomato.EdiblePortion)));
        Assert.Equal(3, exact.Trips!.Single().Items.Single().Packs);
    }

    [Fact]
    public void Ngoai_quay_thit_ca_rau_qua_hoac_o_sieu_thi_van_theo_goi_va_theo_tuan_khong_doi()
    {
        // quầy khác (trứng/đậu phụ) ở chợ vẫn theo gói: đậu phụ là Theo ngày
        var tofu = Build(Meal(0, ("dau_phu", 40))).Trips!.Single().Items.Single();
        Assert.Null(tofu.SoldByWeight);
        Assert.Equal(Data.PricesByIngredient["dau_phu"]["cho_khac"].PackG, tofu.PackG);
        // siêu thị có giá gói: 25 g thịt → 1 gói
        var bhx = BuildAt("bach_hoa_xanh", Meal(0, ("thit_heo_xay_nac", 25))).Trips!.Single().Items.Single();
        Assert.Null(bhx.SoldByWeight);
        Assert.Equal((1, 200.0), (bhx.Packs, bhx.PackG));
        // items (cả tuần) và till_cost vẫn theo gói
        var week = Build(Meal(0, ("uc_ga_khong_da", 25)));
        Assert.Null(week.Items.Single().SoldByWeight);
        Assert.Equal(Data.PricesByIngredient["uc_ga_khong_da"]["cho_khac"].PackG, week.Items.Single().PackG);
    }

    [Fact]
    public void Cong_tac_cap_dong_chuyen_thit_ca_cap_dong_duoc_sang_theo_tuan()
    {
        var list = BuildAt("bach_hoa_xanh", Meal(0, ("thit_heo_xay_nac", 100), ("sup_lo_xanh", 100)), Meal(3, ("thit_heo_xay_nac", 100), ("sup_lo_xanh", 100)));
        var off = ShoppingGroups.TillTotals(list, new HashSet<string>(), freezeMeat: false);
        var on = ShoppingGroups.TillTotals(list, new HashSet<string>(), freezeMeat: true);
        var chicken = list.Items.Single(i => i.IngredientId == "thit_heo_xay_nac");
        Assert.Equal(0, off.Week);
        Assert.Equal(Shopping.RoundMoney(chicken.TillCostVnd), on.Week);
        Assert.True(on.Day < off.Day); // thịt rút khỏi các đợt
        // thịt mua cả tuần một lần (1 gói) rẻ hơn hai gói của hai đợt ở siêu thị
        Assert.True(on.Total < off.Total);
    }

    [Fact]
    public void Nha_co_san_khong_tinh_vao_tong_tien_ca_hai_che_do()
    {
        var list = Build(Meal(0, ("toi", 10), ("gung", 10), ("sup_lo_xanh", 100)));
        var none = ShoppingGroups.TillTotals(list, new HashSet<string>(), false);
        var home = ShoppingGroups.TillTotals(list, new HashSet<string> { "toi", "gung" }, false);
        Assert.True(home.Total < none.Total);
        Assert.Equal("day", list.Items.Single(i => i.IngredientId == "toi").BuyGroup); // tỏi là Theo ngày nhưng có thể là đồ nhà có sẵn
    }

    [Fact]
    public void Dong_0_g_khong_tao_dot_mua_va_khong_lam_hong_danh_sach()
    {
        var only0 = Build(Meal(0, ("uc_ga_khong_da", 0), ("sup_lo_xanh", 100)));
        Assert.DoesNotContain(only0.Items, i => i.IngredientId == "uc_ga_khong_da");
        Assert.DoesNotContain(only0.Trips!.SelectMany(t => t.Items), i => i.IngredientId == "uc_ga_khong_da");
        // ngày dùng 0 g ở giữa không kéo dài đợt và không tạo đợt riêng
        var mixed = Build(Meal(0, ("uc_ga_khong_da", 150)), Meal(1, ("uc_ga_khong_da", 0)), Meal(2, ("uc_ga_khong_da", 0)));
        Assert.Equal([0], mixed.Trips!.Select(t => t.DayIndex));
    }

    [Fact]
    public void Che_do_parity_khong_co_truong_moi()
    {
        var list = Shopping.BuildShoppingList([Meal(0, ("uc_ga_khong_da", 150))], new Household(1, 0), Data, "cho_khac");
        Assert.Null(list.Trips);
        Assert.All(list.Items, i => Assert.Null(i.BuyGroup));
    }

    [Fact]
    public void Mau_ngan_sach_khong_doi_va_gram_bao_toan_voi_18_ho_so()
    {
        var checkedProfiles = 0;
        foreach (var tp in Profiles)
        {
            var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = tp.Preferences, Data = Data, StartDate = "2026-11-09", Seed = 1 });
            var list = plan.Shopping;
            Assert.NotEmpty(list.Trips!);

            // Chi phí món ăn (so với ngân sách) tính từ gram dùng — không phụ thuộc cách chia đợt.
            var flat = Shopping.BuildShoppingList(
                plan.Days.SelectMany((d, di) => d.Meals.Where(m => m.Status == "planned").Select(m => ToShopping(m, di))).Select(m => new ShoppingMeal { Day = 0, Ingredients = m.Ingredients }),
                new Household(tp.Preferences.Adults, tp.Preferences.Children), Data, tp.Preferences.StoreId, null, displayQty: true);
            Assert.Equal(flat.WeekFoodCost, list.WeekFoodCost);
            Assert.Equal(flat.TillCost, list.TillCost);

            // Gram mỗi nguyên liệu Theo ngày qua các đợt = tổng cả tuần; dùng cùng tiền theo gram.
            // Nhóm mua phải dùng đúng dữ liệu bảo quản (lỗi từng gặp: Dataset dựng lại trong kế hoạch làm mất storage → mọi dòng "chưa có thông tin").
            foreach (var it in list.Items)
            {
                var expect = ShoppingGroups.Classify(Data, it.IngredientId);
                Assert.Equal(expect.NoShelfInfo, it.NoShelfInfo);
                Assert.Equal(expect.FreshDays, it.FreshDays);
                Assert.Equal(expect.FreezableMeat, it.FreezableMeat);
                Assert.Equal(expect.Group == BuyMode.Day ? "day" : "week", it.BuyGroup);
            }
            var tripItems = list.Trips!.SelectMany(t => t.Items).ToList();
            foreach (var g in tripItems.GroupBy(i => i.IngredientId))
            {
                var week = list.Items.Single(i => i.IngredientId == g.Key);
                Assert.Equal("day", week.BuyGroup);
                Assert.Equal(week.NeedG, g.Sum(i => i.NeedG), 6);
                Assert.Equal(week.UsedCostVnd, g.Sum(i => i.UsedCostVnd), 4);
                // T-116b: lượng mua (gói hoặc cân) ≥ lượng dùng ở từng đợt
                Assert.All(g, i => Assert.True(i.Packs * i.PackG >= i.NeedG - 1e-6, $"{tp.Id} {g.Key}: mua {i.Packs * i.PackG} g < dùng {i.NeedG} g"));
                Assert.All(g.Where(i => i.SoldByWeight == true), i => Assert.True(i.PackG == 100 && i.Packs >= 1 && i.Packs * 100 - i.NeedG < 100 + 1e-6));
            }
            Assert.Equal(list.Items.Where(i => i.BuyGroup == "day").Select(i => i.IngredientId).OrderBy(x => x), tripItems.Select(i => i.IngredientId).Distinct().OrderBy(x => x));
            Assert.Equal(list.Trips!.Select(t => t.DayIndex).OrderBy(x => x), list.Trips!.Select(t => t.DayIndex));
            Assert.All(list.Trips!, t => Assert.InRange(t.DayIndex, 0, 6));

            // Tổng cả tuần = tuần + các đợt, ở cả hai trạng thái công tắc (chênh so với mua một lần có dấu, không ràng buộc ≥ nữa).
            var pantry = list.Items.Where(i => i.IsPantry == true).Select(i => i.IngredientId).ToHashSet();
            foreach (var freeze in new[] { false, true })
            {
                var t = ShoppingGroups.TillTotals(list, pantry, freeze);
                Assert.Equal(t.Week + t.Day, t.Total);
            }
            checkedProfiles++;
        }
        Assert.Equal(18, checkedProfiles);
    }

    private static ShoppingMeal ToShopping(PlanMeal m, int day)
    {
        var ing = new List<ShoppingIngredient>();
        for (var i = 0; i < m.Grams.Count; i++) ing.Add(new ShoppingIngredient(m.Grams[i].IngredientId, m.Grams[i].Grams, m.StandardGrams[i].Grams));
        foreach (var e in m.Extras) ing.Add(new ShoppingIngredient(e.IngredientId, e.Grams, 0));
        if (m.DessertId is not null && m.Dessert is not null)
        {
            var dr = Data.RecipesById[m.DessertId];
            for (var i = 0; i < m.Dessert.Count; i++) ing.Add(new ShoppingIngredient(m.Dessert[i].IngredientId, m.Dessert[i].Grams, dr.Ingredients[i].Grams));
        }
        return new ShoppingMeal { Day = day, Ingredients = ing };
    }
}
