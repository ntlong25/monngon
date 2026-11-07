namespace MonNgon.Engine.Tests;

public static class TestPaths
{
    /// <summary>Thư mục gốc repo (chứa data/ và golden/).</summary>
    public static string Root { get; } = FindRoot();
    public static string Data => Path.Combine(Root, "data");
    public static string Golden => Path.Combine(Root, "golden");
    public static string Fixtures => Path.Combine(Root, "src", "engine", "__fixtures__");

    private static string FindRoot()
    {
        for (var d = new DirectoryInfo(AppContext.BaseDirectory); d is not null; d = d.Parent)
            if (Directory.Exists(Path.Combine(d.FullName, "src", "engine")) && Directory.Exists(Path.Combine(d.FullName, "data"))) return d.FullName;
        throw new DirectoryNotFoundException("Không tìm thấy thư mục gốc repo");
    }
}
