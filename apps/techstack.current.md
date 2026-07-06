See [[TechStackFile]] for the long-running design idea about a portable `techstack.yml` manifest.
# Current tech stack — Python vs Node.js vs C#

A side-by-side rollup of what I actually reach for in each language ecosystem. Multiple entries in a cell are ordered by preference (first = default, others = fallback or legacy). 

Sources: Python project setup, and the .csproj inventory across a few recent C# repos.


I generated this from 
- [ ] Source my current js and python projects to get more details on this

## Build & language toolchain

| Category                                | [[python]]                    | [[javascript]] / Node        | C# / [[dotnet]]                           |
| --------------------------------------- | ----------------------------- | ---------------------------- | ----------------------------------------- |
| Runtime                                 | CPython 3.12+                 | Node.js 22                   | .NET 8 (range: netcoreapp3.1 → net9.0)    |
| Language                                | Python (type-hinted)          | JS + JSDoc (`tsc --checkJs`) | C# (`ImplicitUsings`, `Nullable enable`)  |
| Project manifest                        | `pyproject.toml`              | `package.json`               | `*.csproj`                      |
| Package manager                         | uv, [[pip]], [[hatch]]        | pnpm, npm                    | NuGet (`<PackageReference>`)              |
| Runtime version mgr                     | uv, pyenv, [[mise]]           | [[mise]], fnm, nvm           | global SDK install                        |
| [[docker.images\|Container base image]] | *❓alpine*, `python:3.12-slim` | `node:22-alpine`             | `mcr.microsoft.com/dotnet/sdk:8.0-alpine` |

## Quality Tooling

| Category         | Python                                              | Node                                     | C#                                              |
| ---------------- | --------------------------------------------------- | ---------------------------------------- | ----------------------------------------------- |
| Linter           | [[ruff]]                                            | ESLint                                   | Roslyn analyzers (compiler built-in)            |
| Formatter        | [[ruff]]                                            | Prettier                                 | `dotnet format`                                 |
| Type checker     | ty (Astral), mypy                                   | `tsc --allowJs --checkJs` (no emit)      | csc (compiler built-in)                         |
| Pre-commit hooks | [pre-commit](https://pre-commit.com/) (global tool) | ❓husky + lint-staged                      |                                                 |
| Test runner      | pytest                                              | `node:test` (built-in)                   | MSTest                                          |
| Coverage         | pytest-cov                                          | ❓`node:test --experimental-test-coverage` | ❓coverlet.collector                              |
| Benchmarks       | ❓pytest-benchmark                                   | ❓tinybench                               | [BenchmarkDotNet](https://benchmarkdotnet.org/) |

## Runtime Libraries

| Category           | Python                           | Node                               | C#                                     |
| ------------------ | -------------------------------- | ---------------------------------- | -------------------------------------- |
| HTTP client        | requests                         | `fetch` (built-in)                 | `System.Net.Http.HttpClient`           |
| Schema validation  | Pydantic                         | ❓Zod, Valibot                      | ❓DataAnnotations, FluentValidation     |
| Logging            | stdlib `logging`                 | ❓Powertools Logger, pino           | ❓`Microsoft.Extensions.Logging`        |
| JWT verify         | `pyjwt[crypto]`                  | ❓`jsonwebtoken` + `jwks-rsa`       | `System.IdentityModel.Tokens.Jwt`      |
| Env loading        | `pytest-dotenv`                  | `dotenv`                           | ❓`IConfiguration` (env-var binding)    |
| Web/HTTP framework | ❓FastAPI, Flask                  | ❓hono, Powertools TS, Express      | ASP.NET Core (`Microsoft.NET.Sdk.Web`) |
| OpenAPI codegen    | `datamodel-code-generator`       | ❓orval, openapi-typescript         | ❓NSwag                                 |
| AWS SDK            | boto3                            | ❓`@aws-sdk/*` v3                   | ❓`AWSSDK.*`                            |
| Lambda bundler     | `serverless-python-requirements` | esbuild (via `serverless-esbuild`) | `dotnet lambda package`                |

## Hosting / Deploy Targets
See [[webapp.hosting]]

| Target             | Python                      | Node          | C#                                |
| ------------------ | --------------------------- | ------------- | --------------------------------- |
| Serverless         | AWS Lambda (serverless CLI) | GCP Cloud Run | AWS Lambda (.NET 8 runtime)       |
| Container PaaS     | AWS ECR                     | —             | [[hosting.fly]] (fly.toml)        |
