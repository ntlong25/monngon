namespace MonNgon.Engine;

/// <summary>mulberry32 — phép 32-bit không dấu giống bản TS (<c>&gt;&gt;&gt; 0</c>, <c>Math.imul</c>).</summary>
public sealed class Rng(long seed)
{
    private uint _a = unchecked((uint)seed);

    public double Next()
    {
        unchecked
        {
            _a += 0x6d2b79f5u;
            var t = _a;
            t = (t ^ (t >> 15)) * (t | 1u);
            t ^= t + (t ^ (t >> 7)) * (t | 61u);
            return (t ^ (t >> 14)) / 4294967296.0;
        }
    }

    /// <summary>Trộn seed gốc với số vòng để mỗi vòng thử có chuỗi ngẫu nhiên riêng nhưng vẫn tất định.</summary>
    public static long DeriveSeed(long seed, int n)
    {
        unchecked
        {
            var s = (uint)seed;
            var m = (uint)(n + 1) * 0x9e3779b1u;
            return (s ^ m) * 0x85ebca6bu;
        }
    }
}
