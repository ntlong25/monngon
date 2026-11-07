using System.Text.Json;
using System.Text.Json.Serialization;

namespace MonNgon.Engine.Data;

public static class JsonOptions
{
    /// <summary>snake_case, bỏ qua khóa lạ.</summary>
    public static readonly JsonSerializerOptions Default = Create();

    public static JsonSerializerOptions Create() => new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        DefaultIgnoreCondition = JsonIgnoreCondition.Never,
    };
}
