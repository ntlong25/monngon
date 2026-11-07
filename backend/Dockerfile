# API FitPro - Mâm đủ (T-068). Build context = GỐC repo (cần data/ và content/):
#   docker build -f backend/Dockerfile -t fitpro-api .
# Xem docs/dev/deploy.md.

# ---- build ----
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /src
# Restore trước để cache lớp NuGet khi chỉ đổi mã.
COPY backend/Directory.Build.props backend/
COPY backend/MonNgon.Engine/MonNgon.Engine.csproj backend/MonNgon.Engine/
COPY backend/MonNgon.Api/MonNgon.Api.csproj backend/MonNgon.Api/
RUN dotnet restore backend/MonNgon.Api/MonNgon.Api.csproj
COPY backend/MonNgon.Engine backend/MonNgon.Engine
COPY backend/MonNgon.Api backend/MonNgon.Api
RUN dotnet publish backend/MonNgon.Api/MonNgon.Api.csproj -c Release -o /out --no-restore /p:UseAppHost=false

# ---- runtime ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS runtime
WORKDIR /app
COPY --from=build /out .
# Dữ liệu và nội dung được COPY vào image làm mặc định; compose/triển khai có thể mount đè (xem docs/dev/deploy.md).
COPY data /app/data
COPY content /app/content
ENV DataDir=/app/data \
    ContentDir=/app/content \
    ASPNETCORE_HTTP_PORTS=8080 \
    DOTNET_EnableDiagnostics=0
EXPOSE 8080
# Không chạy bằng root: user "app" (UID 1654) có sẵn trong image .NET.
USER $APP_UID
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
ENTRYPOINT ["dotnet", "MonNgon.Api.dll"]
