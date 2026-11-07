using MonNgon.Api;
using MonNgon.Engine;
using MonNgon.Engine.Data;

var builder = WebApplication.CreateBuilder(args);

// Thư mục dữ liệu: cấu hình "DataDir", mặc định tìm ./data rồi lên các thư mục cha.
var dataDir = builder.Configuration["DataDir"] ?? FindUp("data", "recipes.json") ?? "data";
var contentDir = builder.Configuration["ContentDir"] ?? FindUp("content", "swipe-cards.json") ?? FindUp(Path.Combine("docs", "research", "content-draft"), "swipe-cards.json");
Dataset dataset;
try
{
    dataset = Dataset.LoadDirectory(dataDir);
}
catch (DataException e)
{
    // Không khởi động nếu dữ liệu lỗi; log chỉ rõ file + id + trường.
    foreach (var i in e.Issues) Console.Error.WriteLine(i);
    Console.Error.WriteLine($"Dữ liệu trong \"{dataDir}\" không hợp lệ: {e.Issues.Count} lỗi. API không khởi động.");
    return 1;
}
builder.Services.AddSingleton(dataset);
builder.Services.AddSingleton(new DataInfo(dataDir, DataVersion.Compute(dataDir), contentDir));

// JSON snake_case cho mọi request/response.
builder.Services.ConfigureHttpJsonOptions(o =>
{
    o.SerializerOptions.PropertyNamingPolicy = JsonOptions.Default.PropertyNamingPolicy;
    o.SerializerOptions.DictionaryKeyPolicy = null;
    // Số chỉ là number/integer trong OpenAPI (mặc định "web" cho phép đọc số từ chuỗi → schema union number|string làm client Dart sinh sai kiểu).
    o.SerializerOptions.NumberHandling = System.Text.Json.Serialization.JsonNumberHandling.Strict;
});
builder.Services.AddProblemDetails();
builder.Services.AddCors(o => o.AddPolicy("dev", p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));
builder.Services.AddOpenApi();

var app = builder.Build();
app.UseExceptionHandler();
app.UseStatusCodePages();
app.UseCors("dev");
app.MapGet("/health", () => Results.Ok(new { status = "ok" })).ExcludeFromDescription();
app.MapV1();
app.MapOpenApi("/openapi/{documentName}.json");
app.Run();
return 0;

static string? FindUp(string dirName, string mustContain)
{
    for (var d = new DirectoryInfo(AppContext.BaseDirectory); d is not null; d = d.Parent)
    {
        var p = Path.Combine(d.FullName, dirName);
        if (File.Exists(Path.Combine(p, mustContain))) return p;
    }
    return null;
}

public partial class Program;
