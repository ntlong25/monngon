using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

public class FilterTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);

    private static HashSet<string> Banned(params string[] exclusions) =>
        Filter.BannedIngredients(Data.Ingredients, new Preferences { Exclusions = [.. exclusions] }).Keys.ToHashSet();

    private static IEnumerable<string> WithTag(string tag) => Data.Ingredients.Where(i => i.AllergenTags.Contains(tag)).Select(i => i.Id);

    [Fact]
    public void No_seed_cam_ca_hat_giong_va_vung_D_QA_01()
    {
        var banned = Banned("no_seed");
        Assert.Contains("vung", banned); // L-03: vừng chỉ có tag sesame
        foreach (var id in WithTag("seed").Concat(WithTag("sesame"))) Assert.Contains(id, banned);
    }

    [Fact]
    public void No_sesame_chi_cam_vung_khong_cam_hat_giong_khac()
    {
        var banned = Banned("no_sesame");
        foreach (var id in WithTag("sesame")) Assert.Contains(id, banned);
        foreach (var id in WithTag("seed").Except(WithTag("sesame"))) Assert.DoesNotContain(id, banned);
    }

    [Fact]
    public void No_seed_khong_cam_lac_hay_hat_cay()
    {
        var banned = Banned("no_seed");
        foreach (var id in WithTag("peanut").Concat(WithTag("tree_nut")).Except(WithTag("seed")).Except(WithTag("sesame"))) Assert.DoesNotContain(id, banned);
    }

    /// <summary>D-QA-06 / L-05: "Không hạt cây" không loại món chứa lạc khỏi tập hợp lệ (lạc là họ đậu, không phải hạt cây).</summary>
    [Fact]
    public void Khong_hat_cay_giu_mon_chua_lac_trong_tap_hop_le()
    {
        var peanutIds = WithTag("peanut").ToHashSet();
        Assert.NotEmpty(peanutIds);
        var withPeanut = Data.Recipes.Where(r => r.Ingredients.Any(i => peanutIds.Contains(i.IngredientId))).Select(r => r.Id).ToList();
        Assert.NotEmpty(withPeanut);
        var prefs = new Preferences { Exclusions = ["no_tree_nut"] };
        var res = Filter.FilterRecipes(Data.Recipes, Data.IngredientsById, Data.Ingredients, prefs);
        var valid = res.Valid.Select(v => v.Recipe.Id).ToHashSet();
        // mọi món có lạc mà KHÔNG có hạt cây khác phải còn hợp lệ
        var treeNut = WithTag("tree_nut").ToHashSet();
        foreach (var id in withPeanut)
        {
            var r = Data.RecipesById[id];
            if (r.Ingredients.Any(i => treeNut.Contains(i.IngredientId))) continue;
            if (res.Excluded.TryGetValue(id, out var why) && why.All(w => w.StartsWith("ingredient:", StringComparison.Ordinal) is false)) continue; // loại vì lý do khác (thiết bị, vai trò…)
            Assert.Contains(id, valid);
        }
    }
}
