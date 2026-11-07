using System.Text.Json;
using System.Text.Json.Nodes;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

// Port của src/data/validate.test.ts
public class DataValidatorTests
{
    private static JsonNode Load(string name) => JsonNode.Parse(File.ReadAllText(Path.Combine(TestPaths.Fixtures, name + ".json")))!;

    private sealed class Raw
    {
        public JsonNode Ingredients = Load("ingredients");
        public JsonNode Recipes = Load("recipes");
        public JsonNode Stores = Load("stores");
        public JsonNode Prices = Load("prices");

        public RawDataset ToRaw() => new()
        {
            Ingredients = JsonDocument.Parse(Ingredients.ToJsonString()).RootElement,
            Recipes = JsonDocument.Parse(Recipes.ToJsonString()).RootElement,
            Stores = JsonDocument.Parse(Stores.ToJsonString()).RootElement,
            Prices = JsonDocument.Parse(Prices.ToJsonString()).RootElement,
        };
        public List<DataIssue> All() => DataValidator.Validate(ToRaw()).Issues.ToList();
        public List<DataIssue> Errors() => All().Where(i => i.Severity == "error").ToList();
    }

    [Fact] public void Fixture_hop_le_0_loi() => Assert.Empty(new Raw().Errors());

    [Fact]
    public void Loi_schema_chi_ro_file_id_truong()
    {
        var r = new Raw();
        r.Ingredients[0]!["aisle"] = "khong_co";
        var e = r.Errors()[0];
        Assert.Equal(("ingredients", "uc_ga_khong_da", "aisle"), (e.File, e.Id, e.Field));
        Assert.Contains("ingredients.json · uc_ga_khong_da · aisle", e.ToString());
    }

    [Fact]
    public void Id_sai_dinh_dang()
    {
        var r = new Raw();
        r.Recipes[0]!["id"] = "Ức gà";
        Assert.Contains(r.Errors(), e => e.File == "recipes" && e.Field == "id");
    }

    [Fact]
    public void Id_trung()
    {
        var r = new Raw();
        ((JsonArray)r.Ingredients).Add(r.Ingredients[0]!.DeepClone());
        Assert.Contains(r.Errors(), e => e.Message.Contains("trùng") && e.Id == "uc_ga_khong_da");
    }

    [Fact]
    public void Tham_chieu_ingredient_khong_ton_tai_trong_recipe()
    {
        var r = new Raw();
        r.Recipes[0]!["ingredients"]![0]!["ingredient_id"] = "ma_ghe";
        Assert.Contains(r.Errors(), e => e is { File: "recipes", Id: "uc_ga_xao_sup_lo_toi", Field: "ingredients[0].ingredient_id" });
    }

    [Fact]
    public void Tham_chieu_store_va_ingredient_khong_ton_tai_trong_price()
    {
        var r = new Raw();
        ((JsonArray)r.Prices).Add(JsonNode.Parse("""{"ingredient_id":"ma_ghe","store_id":"cho_ao","pack_g":100,"pack_label":"x","price_vnd":1,"shelf_life_days":1}"""));
        var fields = r.Errors().Where(e => e.File == "prices").Select(e => e.Field).ToList();
        Assert.Contains("ingredient_id", fields);
        Assert.Contains("store_id", fields);
    }

    [Fact]
    public void Min_grams_max()
    {
        var r = new Raw();
        r.Recipes[0]!["ingredients"]![0]!["min_g"] = 200;
        Assert.Contains(r.Errors(), e => e.Field == "ingredients[0].grams");
    }

    [Fact]
    public void Vai_tro_khong_phai_protein_carb_phai_co_dinh()
    {
        var r = new Raw();
        r.Recipes[0]!["ingredients"]![2]!["max_g"] = 300;
        Assert.Contains(r.Errors(), e => e.Field == "ingredients[2].min_g/max_g");
    }

    [Fact]
    public void Is_low_carb_yeu_cau_carb_min_0()
    {
        var r = new Raw();
        r.Recipes[0]!["ingredients"]![1]!["min_g"] = 50;
        Assert.Contains(r.Errors(), e => e.Field == "is_low_carb");
    }

    [Fact]
    public void Moi_nguyen_lieu_phai_co_gia_cho_khac()
    {
        var r = new Raw();
        var arr = (JsonArray)r.Prices;
        foreach (var n in arr.Where(p => p!["ingredient_id"]!.GetValue<string>() == "dau_phu" && p["store_id"]!.GetValue<string>() == "cho_khac").ToList()) arr.Remove(n);
        Assert.Contains(r.Errors(), e => e.File == "prices" && e.Id == "dau_phu@cho_khac");
    }

    [Fact]
    public void Kcal_lech_la_canh_bao_khong_phai_loi()
    {
        var r = new Raw();
        r.Ingredients[0]!["per_100g"]!["kcal"] = 300;
        var all = r.All();
        Assert.Contains(all, i => i.Severity == "warning" && i.Id == "uc_ga_khong_da");
        Assert.DoesNotContain(all, i => i.Severity == "error");
    }

    [Fact]
    public void Khong_phai_mang_la_loi_root()
    {
        var r = new Raw { Stores = JsonNode.Parse("""{"a":1}""")! };
        Assert.Contains(r.Errors(), e => e is { File: "stores", Field: "(root)" });
    }

    [Fact]
    public void KcalDeviation_rau_it_kcal_van_dat_nho_xo()
        => Assert.True(DataValidator.KcalDeviation(new MacrosPer100g { Kcal = 34, ProteinG = 2.8, CarbG = 6.6, FatG = 0.4, FiberG = 2.6 }) < 0.15);

    [Fact]
    public void Load_index_theo_id_va_gia_fallback()
    {
        var ds = Dataset.LoadDirectory(TestPaths.Fixtures.Replace("\\", "/"));
        Assert.Equal("Cơm trắng", ds.IngredientsById["com_trang"].Name);
        Assert.Equal(7, ds.RecipesById.Count);
        Assert.False(ds.FindPrice("uc_ga_khong_da", "winmart")!.Value.Fallback);
        Assert.True(ds.FindPrice("uc_ga_khong_da", "coopmart")!.Value.Fallback);
        Assert.Null(ds.FindPrice("khong_co", "winmart"));
    }

    [Fact]
    public void Load_nem_loi_khi_sai_schema()
    {
        var r = new Raw();
        r.Ingredients[0]!["aisle"] = "x";
        var ex = Assert.Throws<DataException>(() => Dataset.Load(r.ToRaw()));
        Assert.Contains("uc_ga_khong_da", ex.Message);
    }

    [Fact]
    public void Du_lieu_that_khong_loi_va_nap_duoc()
    {
        var res = DataValidator.Validate(RawDataset.ReadDirectory(TestPaths.Data));
        Assert.Equal(0, res.Errors);
        Assert.True(res.Dataset.Recipes.Count > 100);
        // v0.2: dish_role được đọc
        Assert.Contains(res.Dataset.Recipes, x => x.DishRole == "soup");
    }
}
