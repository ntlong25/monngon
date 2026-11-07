using System.Text.Json;
using System.Text.Json.Nodes;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>D-SHP-02 / T-078 phần 2: `purchase_as` quy cơm chín ra gạo sống ở danh sách đi chợ và chi phí; chế độ parity không áp dụng.</summary>
public class PurchaseAsTests
{
    private static readonly Dataset Base = Dataset.LoadDirectory(TestPaths.Data);

    private static ShoppingMeal Meal(params (string Id, double G)[] lines) =>
        new() { Ingredients = lines.Select(l => new ShoppingIngredient(l.Id, l.G, l.G)).ToList() };

    [Fact]
    public void Du_lieu_that_khai_bao_purchase_as_cho_com_trang_va_gao_lut()
    {
        Assert.Equal(("gao_te", 0.36), (Base.IngredientsById["com_trang"].PurchaseAs!.IngredientId, Base.IngredientsById["com_trang"].PurchaseAs!.Factor));
        Assert.Equal(("gao_lut", 0.34), (Base.IngredientsById["gao_lut_nau_chin"].PurchaseAs!.IngredientId, Base.IngredientsById["gao_lut_nau_chin"].PurchaseAs!.Factor));
    }

    [Fact]
    public void Com_1000_g_thanh_360_g_gao_va_1_bao_1_kg()
    {
        var list = Shopping.BuildShoppingList([Meal(("com_trang", 1000))], new Household(1, 0), Base, "cho_khac", [], displayQty: true);
        Assert.DoesNotContain(list.Items, i => i.IngredientId == "com_trang");
        var rice = Assert.Single(list.Items, i => i.IngredientId == "gao_te");
        Assert.Equal(360, rice.NeedG, 6);
        Assert.Equal(1, rice.Packs);
        Assert.Equal(1000, rice.PackG);
        Assert.Equal(360 / 1000.0 * rice.PriceVndPerPack, rice.UsedCostVnd, 6);
        Assert.Equal(rice.PriceVndPerPack, rice.TillCostVnd, 6);
    }

    [Fact]
    public void Gop_nhieu_bua_va_nguoi_cung_an_vao_nguyen_lieu_dich()
    {
        // 2 bữa × 200 g cơm của "bạn", 1 người lớn nữa ăn khẩu phần chuẩn 200 g mỗi bữa → (200 + 200) × 2 × 0,36
        var list = Shopping.BuildShoppingList([Meal(("com_trang", 200)), Meal(("com_trang", 200), ("gao_te", 50))], new Household(2, 0), Base, "cho_khac", [], displayQty: true);
        Assert.Equal((400 + 400) * 0.36 + 50 * 2, Assert.Single(list.Items, i => i.IngredientId == "gao_te").NeedG, 6);
    }

    [Fact]
    public void Gao_te_la_pantry_mac_dinh_nen_khong_vao_tien_tai_quay_nhung_van_vao_chi_phi_mon_an()
    {
        var withPantry = Shopping.BuildShoppingList([Meal(("com_trang", 1000))], new Household(1, 0), Base, "cho_khac", null, displayQty: true);
        var none = Shopping.BuildShoppingList([Meal(("com_trang", 1000))], new Household(1, 0), Base, "cho_khac", [], displayQty: true);
        Assert.True(withPantry.Items.Single().IsPantry);
        Assert.Equal(0, withPantry.TillCost);
        Assert.Equal(none.WeekFoodCost, withPantry.WeekFoodCost);
        Assert.True(withPantry.PantryCostIfBuyVnd > 0);
    }

    [Fact]
    public void Che_do_parity_khong_quy_doi()
    {
        var list = Shopping.BuildShoppingList([Meal(("com_trang", 1000))], new Household(1, 0), Base, "cho_khac");
        Assert.Contains(list.Items, i => i.IngredientId == "com_trang");
        Assert.DoesNotContain(list.Items, i => i.IngredientId == "gao_te");
        var c = Shopping.ServingCostVnd([new GramLine("com_trang", 100)], Base, "cho_khac", purchaseAs: false);
        var cPa = Shopping.ServingCostVnd([new GramLine("com_trang", 100)], Base, "cho_khac");
        Assert.Equal(100 / 1000.0 * 12000, c, 6); // giá dòng cơm nấu chín cũ
        Assert.Equal(100 * 0.36 / 1000.0 * 22000, cPa, 6);
    }

    // --- validator ---

    private static List<DataIssue> Validate(Action<JsonNode> edit)
    {
        var ing = JsonNode.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "ingredients.json")))!;
        edit(ing);
        var raw = new RawDataset
        {
            Ingredients = JsonDocument.Parse(ing.ToJsonString()).RootElement,
            Recipes = JsonDocument.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "recipes.json"))).RootElement,
            Stores = JsonDocument.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "stores.json"))).RootElement,
            Prices = JsonDocument.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "prices.json"))).RootElement,
        };
        return DataValidator.Validate(raw).Issues.Where(i => i.Severity == "error").ToList();
    }

    private static JsonNode Com(JsonNode ing) => ing.AsArray().First(i => i!["id"]!.GetValue<string>() == "com_trang")!;

    [Fact]
    public void Nguyen_lieu_co_purchase_as_khong_can_gia_cho_khac_rieng()
    {
        var ing = JsonNode.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "ingredients.json")))!;
        var prices = JsonNode.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "prices.json")))!.AsArray();
        foreach (var p in prices.Where(p => p!["ingredient_id"]!.GetValue<string>() is "com_trang" or "gao_lut_nau_chin").ToList()) prices.Remove(p);
        var raw = new RawDataset
        {
            Ingredients = JsonDocument.Parse(ing.ToJsonString()).RootElement,
            Recipes = JsonDocument.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "recipes.json"))).RootElement,
            Stores = JsonDocument.Parse(File.ReadAllText(Path.Combine(TestPaths.Data, "stores.json"))).RootElement,
            Prices = JsonDocument.Parse(prices.ToJsonString()).RootElement,
        };
        Assert.DoesNotContain(DataValidator.Validate(raw).Issues, i => i.Severity == "error");
        // nguyên liệu không có purchase_as vẫn bắt buộc có giá cho_khac
        prices.Remove(prices.First(p => p!["ingredient_id"]!.GetValue<string>() == "dau_phu" && p["store_id"]!.GetValue<string>() == "cho_khac"));
        raw = new RawDataset { Ingredients = raw.Ingredients, Recipes = raw.Recipes, Stores = raw.Stores, Prices = JsonDocument.Parse(prices.ToJsonString()).RootElement };
        Assert.Contains(DataValidator.Validate(raw).Issues, i => i.Severity == "error" && i.Id == "dau_phu@cho_khac");
    }

    [Fact] public void Dich_khong_co_gia_cho_khac_la_loi()
    {
        var e = Validate(ing => ing.AsArray().First(i => i!["id"]!.GetValue<string>() == "gao_te")!["id"] = "gao_te_doi_ten");
        Assert.Contains(e, x => x.Id == "com_trang" && x.Field == "purchase_as.ingredient_id");
    }

    [Fact] public void Du_lieu_that_hop_le() => Assert.Empty(Validate(_ => { }));

    [Theory]
    [InlineData(0.0)]
    [InlineData(-0.2)]
    [InlineData(1.5)]
    public void Factor_ngoai_0_1_la_loi(double factor)
    {
        var e = Validate(ing => Com(ing)["purchase_as"]!["factor"] = factor);
        Assert.Contains(e, x => x.Id == "com_trang" && x.Field.Contains("factor"));
    }

    [Fact]
    public void Nguyen_lieu_dich_khong_ton_tai_la_loi()
    {
        var e = Validate(ing => Com(ing)["purchase_as"]!["ingredient_id"] = "khong_co_gao");
        Assert.Contains(e, x => x.Id == "com_trang" && x.Field == "purchase_as.ingredient_id");
    }

    [Fact]
    public void Tro_ve_chinh_no_hoac_noi_chuoi_la_loi()
    {
        var self = Validate(ing => Com(ing)["purchase_as"]!["ingredient_id"] = "com_trang");
        Assert.Contains(self, x => x.Id == "com_trang" && x.Field == "purchase_as.ingredient_id");
        // gạo tẻ lại trỏ sang gạo lứt → com_trang → gao_te → gao_lut là chuỗi
        var chain = Validate(ing => ing.AsArray().First(i => i!["id"]!.GetValue<string>() == "gao_te")!["purchase_as"] = new JsonObject { ["ingredient_id"] = "gao_lut", ["factor"] = 1.0 });
        Assert.Contains(chain, x => x.Id == "com_trang" && x.Field == "purchase_as.ingredient_id");
    }
}
