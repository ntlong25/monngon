using Microsoft.AspNetCore.Mvc.Testing;

namespace MonNgon.Api.Tests;

public class HealthTests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Health_tra_200()
    {
        var res = await factory.CreateClient().GetAsync("/health");
        Assert.Equal(System.Net.HttpStatusCode.OK, res.StatusCode);
    }
}
