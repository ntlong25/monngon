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

    // ---- T-112: data/storage.json (bảo quản) ----

    private static RawDataset WithStorage(Raw r, JsonNode storage)
    {
        var raw = r.ToRaw();
        return new RawDataset { Ingredients = raw.Ingredients, Recipes = raw.Recipes, Stores = raw.Stores, Prices = raw.Prices, Storage = JsonDocument.Parse(storage.ToJsonString()).RootElement };
    }

    private static JsonObject StorageRow(string ingredientId, string status = "ok") => new()
    {
        ["ingredient_id"] = ingredientId, ["status"] = status, ["fridge_days"] = 3, ["pantry_days"] = null, ["freezer_days"] = 90,
        ["freezable"] = true, ["long_term"] = false, ["tips_vi"] = "Cất ngăn mát.", ["spoilage_signs_vi"] = "Mùi lạ.",
        ["source"] = new JsonObject { ["org"] = "USDA FSIS", ["title"] = "FoodKeeper" },
    };

    private static List<DataIssue> StorageErrors(Raw r, params JsonObject[] rows) =>
        DataValidator.Validate(WithStorage(r, new JsonArray(rows.Select(x => x.DeepClone()).ToArray()))).Issues.Where(i => i.Severity == "error").ToList();

    [Fact]
    public void Storage_hop_le_va_duoc_nap_vao_Dataset()
    {
        var r = new Raw();
        var id = (string)r.Ingredients[0]!["id"]!;
        var res = DataValidator.Validate(WithStorage(r, new JsonArray(StorageRow(id))));
        Assert.DoesNotContain(res.Issues, i => i.Severity == "error");
        Assert.Equal(3, res.Dataset.StorageByIngredient[id].FridgeDays);
        Assert.Null(res.Dataset.StorageByIngredient[id].PantryDays);
        Assert.Equal("USDA FSIS", res.Dataset.StorageByIngredient[id].Source!.Org);
    }

    [Fact]
    public void Khong_co_file_storage_thi_bo_qua_va_Dataset_rong()
    {
        var res = DataValidator.Validate(new Raw().ToRaw());
        Assert.DoesNotContain(res.Issues, i => i.File == "storage");
        Assert.Empty(res.Dataset.Storage);
    }

    [Fact]
    public void Storage_loi_schema_chi_ro_file_id_truong()
    {
        var r = new Raw();
        var id = (string)r.Ingredients[0]!["id"]!;
        Assert.Contains(StorageErrors(r, StorageRow(id, "khong_co")), e => e.File == "storage" && e.Id == id && e.Field == "status");
        var neg = StorageRow(id); neg["fridge_days"] = -1;
        Assert.Contains(StorageErrors(r, neg), e => e.Id == id && e.Field == "fridge_days");
        var frac = StorageRow(id); frac["freezer_days"] = 1.5;
        Assert.Contains(StorageErrors(r, frac), e => e.Id == id && e.Field == "freezer_days");
        var blank = StorageRow(id); blank["tips_vi"] = "";
        Assert.Contains(StorageErrors(r, blank), e => e.Id == id && e.Field == "tips_vi");
    }

    [Fact]
    public void Storage_nguyen_lieu_khong_ton_tai_va_trung_la_loi()
    {
        var r = new Raw();
        var id = (string)r.Ingredients[0]!["id"]!;
        Assert.Contains(StorageErrors(r, StorageRow("khong_co_nguyen_lieu_nay")), e => e.Field == "ingredient_id" && e.Message.Contains("không tồn tại"));
        Assert.Contains(StorageErrors(r, StorageRow(id), StorageRow(id)), e => e.Id == id && e.Message.Contains("trùng"));
    }

    [Fact]
    public void Storage_status_co_so_lieu_phai_co_so_ngay_hoac_long_term_va_nguon()
    {
        var r = new Raw();
        var id = (string)r.Ingredients[0]!["id"]!;
        var noNumber = StorageRow(id);
        noNumber["fridge_days"] = null; noNumber["freezer_days"] = null;
        Assert.Contains(StorageErrors(r, noNumber), e => e.Id == id && e.Field == "status");
        noNumber["long_term"] = true;
        Assert.DoesNotContain(StorageErrors(r, noNumber), e => e.Id == id && e.Field == "status");
        var noSource = StorageRow(id); noSource["source"] = null;
        Assert.Contains(StorageErrors(r, noSource), e => e.Id == id && e.Field == "source");
        // chua_co_nguon: không cần số ngày hay nguồn, chỉ cảnh báo.
        JsonObject None() => new() { ["ingredient_id"] = id, ["status"] = "chua_co_nguon", ["long_term"] = false };
        Assert.Empty(StorageErrors(r, None()));
        var res = DataValidator.Validate(WithStorage(r, new JsonArray(None())));
        Assert.Contains(res.Issues, i => i.Severity == "warning" && i.File == "storage" && i.Message.Contains("chưa có nguồn"));
        var notFreezable = StorageRow(id); notFreezable["freezable"] = false;
        Assert.Contains(StorageErrors(r, notFreezable), e => e.Id == id && e.Field == "freezer_days");
    }

    [Fact]
    public void Storage_du_lieu_that_phu_het_nguyen_lieu_va_co_met_tips_cho_do_tuoi()
    {
        var res = DataValidator.Validate(RawDataset.ReadDirectory(TestPaths.Data));
        Assert.Equal(0, res.Errors);
        Assert.Equal(res.Dataset.Ingredients.Count, res.Dataset.Storage.Count);
        Assert.All(res.Dataset.Ingredients, i => Assert.True(res.Dataset.StorageByIngredient.ContainsKey(i.Id), i.Id));
        // Research: 50 đồ tươi đều có mẹo và dấu hiệu hỏng; mẹo và dấu hiệu luôn đi cùng nhau.
        Assert.True(res.Dataset.Storage.Count(x => !string.IsNullOrWhiteSpace(x.TipsVi)) >= 50);
        Assert.All(res.Dataset.Storage, x => Assert.Equal(string.IsNullOrWhiteSpace(x.TipsVi), string.IsNullOrWhiteSpace(x.SpoilageSignsVi)));
    }

    // ---- T-104: source_note của giá cho_khac ----

    private static JsonObject FirstChoKhac(Raw r, int skip = 0) => ((JsonArray)r.Prices).Select(p => (JsonObject)p!).Where(p => (string?)p["store_id"] == "cho_khac").Skip(skip).First();

    [Fact]
    public void Thieu_source_note_o_cho_khac_la_loi()
    {
        var r = new Raw();
        var p = FirstChoKhac(r);
        p.Remove("source_note");
        Assert.Contains(r.Errors(), e => e.File == "prices" && e.Id == $"{(string)p["ingredient_id"]!}@cho_khac" && e.Field == "source_note");
    }

    [Fact]
    public void Source_note_rong_la_loi_va_cua_hang_khac_khong_bat_buoc()
    {
        var r = new Raw();
        FirstChoKhac(r)["source_note"] = "  ";
        Assert.Single(r.Errors(), e => e.Field == "source_note");
        var r2 = new Raw();
        var clone = (JsonObject)((JsonArray)r2.Prices)[0]!.DeepClone();
        clone["store_id"] = "bach_hoa_xanh";
        clone.Remove("source_note");
        ((JsonArray)r2.Prices).Add(clone);
        Assert.DoesNotContain(r2.Errors(), e => e.Field == "source_note");
    }

    [Fact]
    public void Chua_co_nguon_hop_le_nhung_duoc_dem_va_canh_bao_mot_lan()
    {
        var r = new Raw();
        FirstChoKhac(r)["source_note"] = "chưa có nguồn";
        FirstChoKhac(r, 1)["source_note"] = "Chưa có nguồn";
        Assert.Empty(r.Errors());
        var w = Assert.Single(r.All(), i => i.Severity == "warning" && i.Field == "source_note");
        Assert.Contains("2 dòng", w.Message);
    }
}
