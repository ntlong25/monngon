using System.Globalization;

namespace MonNgon.Engine;

/// <summary>Các helper để C# cho kết quả giống JS (làm tròn, so sánh chuỗi theo ICU).</summary>
public static class Js
{
    /// <summary>Tương đương <c>Math.round</c> của JS: làm tròn .5 về phía +∞ (kể cả số âm); không dùng Math.Round mặc định (làm tròn ngân hàng).</summary>
    public static double Round(double x)
    {
        if (!double.IsFinite(x)) return x;
        var f = Math.Floor(x);
        return x - f >= 0.5 ? f + 1 : f;
    }

    /// <summary>Số → chuỗi như JS cho các khóa so sánh (đủ dùng để phân biệt giá trị).</summary>
    public static string Num(double d) => d.ToString("R", CultureInfo.InvariantCulture);
}

/// <summary>
/// Mô phỏng <c>String.prototype.localeCompare</c> của ICU cho tiếng Việt ('vi') và cho id ASCII:
/// khoảng trắng/dấu câu &lt; chữ số &lt; chữ cái (a &lt; ă &lt; â &lt; b … d &lt; đ … e &lt; ê … o &lt; ô &lt; ơ … u &lt; ư);
/// thanh điệu là mức 2 (không &lt; huyền &lt; hỏi &lt; ngã &lt; sắc &lt; nặng); chữ thường trước chữ hoa ở mức 3.
/// </summary>
public sealed class ViCollator : IComparer<string>
{
    public static readonly ViCollator Instance = new();

    private const string Punct = " _-,;:!?.'\"()[]{}@*/\\&#%`^+<=>|~$";
    // Thứ tự chữ cái tiếng Việt (CLDR 'vi'): ă, â đứng sau a; đ sau d; ê sau e; ô, ơ sau o; ư sau u.
    private const string Order = "aăâbcdđeêfghijklmnoôơpqrstuưvwxyz";

    // Mỗi chuỗi: [không dấu, huyền, sắc, hỏi, ngã, nặng]
    private static readonly int[] ToneWeight = [0, 1, 4, 2, 3, 5];
    private static readonly Dictionary<char, (char Letter, int Tone)> Composed = BuildComposed();

    private static Dictionary<char, (char, int)> BuildComposed()
    {
        var d = new Dictionary<char, (char, int)>();
        void Add(char letter, string forms)
        {
            for (var i = 0; i < forms.Length; i++) d[forms[i]] = (letter, ToneWeight[i]);
        }
        Add('a', "aàáảãạ"); Add('ă', "ăằắẳẵặ"); Add('â', "âầấẩẫậ");
        Add('e', "eèéẻẽẹ"); Add('ê', "êềếểễệ");
        Add('i', "iìíỉĩị");
        Add('o', "oòóỏõọ"); Add('ô', "ôồốổỗộ"); Add('ơ', "ơờớởỡợ");
        Add('u', "uùúủũụ"); Add('ư', "ưừứửữự");
        Add('y', "yỳýỷỹỵ");
        return d;
    }

    private readonly record struct Key(int[] Primary, int[] Secondary, int[] Tertiary);

    private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, Key> Cache = new();

    private static Key MakeKey(string s) => Cache.GetOrAdd(s, BuildKey);

    private static Key BuildKey(string s)
    {
        var prim = new List<int>();
        var sec = new List<int>();
        var ter = new List<int>();
        foreach (var c0 in s)
        {
            var upper = char.IsUpper(c0);
            var c = char.ToLowerInvariant(c0);
            var tone = 0;
            if (Composed.TryGetValue(c, out var comp)) { c = comp.Letter; tone = comp.Tone; }
            var idx = Order.IndexOf(c);
            if (idx >= 0) { prim.Add(1000 + idx); sec.Add(tone); ter.Add(upper ? 1 : 0); }
            else if (c is >= '0' and <= '9') { prim.Add(500 + (c - '0')); sec.Add(0); ter.Add(0); }
            else
            {
                var p = Punct.IndexOf(c);
                prim.Add(p >= 0 ? 100 + p : 300 + c); sec.Add(0); ter.Add(0);
            }
        }
        return new Key([.. prim], [.. sec], [.. ter]);
    }

    private static int Cmp(int[] a, int[] b)
    {
        var n = Math.Min(a.Length, b.Length);
        for (var i = 0; i < n; i++)
            if (a[i] != b[i]) return a[i] < b[i] ? -1 : 1;
        return a.Length.CompareTo(b.Length);
    }

    public int Compare(string? x, string? y)
    {
        if (ReferenceEquals(x, y)) return 0;
        var a = MakeKey(x ?? "");
        var b = MakeKey(y ?? "");
        var c = Cmp(a.Primary, b.Primary);
        if (c != 0) return c;
        c = Cmp(a.Secondary, b.Secondary);
        if (c != 0) return c;
        return Cmp(a.Tertiary, b.Tertiary);
    }
}
