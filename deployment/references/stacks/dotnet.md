# .NET

v1 fully supported: discovery, assessment, generate, validate.

## 1. Discovery

| Signal | Where |
|---|---|
| Solution / projects | `*.sln`, `*.slnx`, `**/*.csproj` |
| SDK / runtime | `global.json` (`sdk.version`), `<TargetFramework(s)>` |
| Central package management | `Directory.Packages.props`, `Directory.Build.props` |
| Private feeds | `nuget.config` `<packageSources>` beyond nuget.org -> CI needs feed credentials (variable names in Manual setup) |
| Ports | §1.1 |
| Health | `AddHealthChecks`, `MapHealthChecks`, `UseHealthChecks`, route literals with `health` |
| Tests | projects referencing `Microsoft.NET.Test.Sdk` (xUnit / NUnit / MSTest); `Testcontainers` / connection strings in test config = needs services |
| Startup migrations | `Database.Migrate()`, `MigrateAsync()`, `EnsureCreated()` in startup -> rollback note (`delivery-strategy.md` §5) |
| Scheduling | Quartz, Hangfire, `PeriodicTimer` in a `BackgroundService`, `cron` strings |

### 1.1 Listening port

"It is ASP.NET Core" is never the evidence (`decision-rules.md` §9). Check, in order,
and cite the first that answers:

1. Existing deployment files: Deployment / Service, compose `ports` / `environment`,
   systemd unit `Environment=ASPNETCORE_URLS`, CI variables.
2. Dockerfile: `ENV ASPNETCORE_HTTP_PORTS` / `ASPNETCORE_URLS`, `EXPOSE`.
3. Application configuration: `Kestrel:Endpoints` / `urls` in `appsettings*.json`
   for the target environment.
4. Code: `UseUrls(...)`, `ConfigureKestrel` / `Listen*(...)`, `WebHost` settings.
5. User statement.
6. The base image's own `ASPNETCORE_HTTP_PORTS` - only when the repository's
   Dockerfile pins that image, nothing in 1-4 overrides it, and the value is **read**
   from the image (`docker image inspect <image> --format '{{json .Config.Env}}'`),
   not recalled. `CONFIRMED: image env`.

`launchSettings.json` is development-only: an `INFERRED` hint at most, never the sole
evidence for a deployed port. Nothing found -> `Unknown` -> Gate 7, asking for the port
(say which mechanism would otherwise decide it, e.g. "no port is configured; the image
default would apply - confirm the port").

## 2. Classification

| Evidence | Type |
|---|---|
| `Sdk="Microsoft.NET.Sdk.Web"` and maps endpoints / controllers | Web API (Frontend if it only serves Razor / Blazor UI) |
| `Sdk="Microsoft.NET.Sdk.Worker"` or `Host.CreateApplicationBuilder` + `AddHostedService` without HTTP | Worker / Background Service |
| `<OutputType>Exe</OutputType>` + `PackAsTool` or argument parsing, no host | CLI |
| `Microsoft.NET.Sdk` class library with `IsPackable` not false, or `PackageId` / package metadata, not referenced only internally | Library / Package |
| Exe that runs once and exits, invoked on a schedule (docs, cron in scripts) | Scheduled Job |

Test projects and internal libraries are not deployable units.

## 3. Build commands

```bash
dotnet restore <sln|csproj>
dotnet build  <sln|csproj> -c Release --no-restore
dotnet test   <sln|csproj> -c Release --no-build
dotnet publish <app.csproj> -c Release --no-build -o ./publish        # runtime apps
dotnet pack    <lib.csproj> -c Release --no-build -o ./artifacts -p:Version=<v>   # packages
```

- SDK image / setup version comes from `global.json`, else the highest
  `TargetFramework` major.
- Add `-p:ContinuousIntegrationBuild=true` to build in CI for deterministic output.
- If `dotnet test` writes results, publish them with the provider's test-report
  mechanism (`--logger trx` / `junit` logger only if the repository already has it).

## 4. Package publishing (Library)

- Trigger: release tag `v<semver>` (push of tag). Version = tag without `v`.
- Non-tag builds pack with `<base>-ci.<sha>` only if the repository publishes
  pre-releases; otherwise CI just packs as validation and publishes nothing.
- `dotnet nuget push ./artifacts/*.nupkg --source <feed> --api-key $<KEY_VAR> --skip-duplicate`
  (`.snupkg` too if symbols are enabled).
- Feed: nuget.org (`NUGET_API_KEY` variable), GitLab package registry (`$CI_JOB_TOKEN`,
  `${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json`), or GitHub
  Packages (`GITHUB_TOKEN` with `packages: write`). Use the one already referenced in
  `nuget.config` / docs; none -> ask (Gate 1 for the publish part).
- Pack once, push that same `.nupkg` (build once, promote many).

## 5. Dockerfile rules

Only when the Container decision is Required and no Dockerfile exists (an existing one
is kept and only fixed if a Finding requires it).

- Multi-stage: `mcr.microsoft.com/dotnet/sdk:<major>` build -> `mcr.microsoft.com/dotnet/aspnet:<major>`
  (Web) or `runtime:<major>` (Worker / console). Major from §3.
- Restore layer first: copy `*.sln`, every `*.csproj`, `Directory.*.props`,
  `nuget.config`, `global.json`, restore, then copy the rest.
- Private feeds in `nuget.config`: credentials via BuildKit secret mount, never `ARG`
  / `ENV`.
- Run as non-root: .NET 8+ images provide `USER $APP_UID`.
- Port: the value from §1.1, set explicitly (`ENV ASPNETCORE_HTTP_PORTS=<port>` +
  `EXPOSE <port>`) so the deployment files and the image agree. `Unknown` -> Gate 7;
  do not write a port number because it is the image's usual default.
- `ENTRYPOINT ["dotnet", "<Assembly>.dll"]`.
- `.dockerignore`: `**/bin`, `**/obj`, `.git`, `.vs`, `.vscode`, `**/*.user`,
  `**/node_modules`, `tests/` if not needed in the build, plus local env files (`.env`,
  `.env.*` except `.env.example`). Reason: the image must stay environment-neutral
  (build once, promote many) - configuration is injected at deploy time. This is about
  the image, not Git: tracked config such as `env/qa.env` is excluded from the build
  context only if the Dockerfile does not `COPY` it, and stays in Git
  (`secrets.md` §3).
- Build context is the repository root when projects reference siblings.

## 6. Minimal health endpoint

Only under Hard Rule 9. Smallest change in `Program.cs`:

```csharp
builder.Services.AddHealthChecks();
// ...
app.MapHealthChecks("/health");
```

- One endpoint serves startup and readiness probes. Dependency checks (DB, Redis) are
  **not** added - they change runtime behaviour (a DB blip would pull every Pod out of
  service) and need packages; offer them as a follow-up.
- Follow an existing path convention if the repository or its siblings have one.
- Respect existing auth: if a global authorization policy applies, the endpoint needs
  `.AllowAnonymous()` - that is part of the listed change.
- Worker without HTTP: no endpoint; rely on process liveness (systemd `Restart=`,
  K8s container restart).

## 7. Runtime configuration

- Environment selection: `ASPNETCORE_ENVIRONMENT` / `DOTNET_ENVIRONMENT` set per
  environment by the target; the name matches the `appsettings.<Env>.json` spelling.
- Overrides via environment variables with `__` nesting (`secrets.md` §3).
- Graceful shutdown: the generic host handles SIGTERM; keep the target's stop timeout
  (K8s `terminationGracePeriodSeconds`, systemd `TimeoutStopSec`) ≥ the host's
  `ShutdownTimeout` (default 30 s).

## 8. Dependency audit (suggestion only)

`dotnet list package --vulnerable --include-transitive` - suggested in the Report;
added to CI only when the user asks (`decision-rules.md` §4).
