# Node.js

v1: **discovery and assessment only.** No new Node build jobs, Dockerfiles or runtime
configuration are generated.

## 1. Discovery

| Signal | Where |
|---|---|
| Package manager | lockfile: `package-lock.json` (npm), `pnpm-lock.yaml`, `yarn.lock`, `bun.lockb` |
| Runtime version | `.nvmrc`, `.node-version`, `engines.node` |
| Scripts | `package.json` `scripts.build / test / lint / start` |
| Workspaces | `workspaces`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json` |
| Framework | dependencies: `next`, `nuxt`, `@sveltejs/kit`, `vite`, `@angular/core`, `react-scripts`, `express`, `fastify`, `@nestjs/core` |
| Health | route literals with `health` / `ready` |

## 2. Classification

| Evidence | Type |
|---|---|
| `express` / `fastify` / `@nestjs/core` with a listen call | Web API |
| SPA build (`vite`, `react-scripts`, Angular) producing static files | Frontend (static) |
| `next` / `nuxt` / SvelteKit with a server adapter | Frontend (server runtime) |
| `bin` field, no server | CLI |
| `main` / `exports`, published (`publishConfig`, no `private: true`) | Library / Package |

## 3. What v1 does with it

- **Assess / Review**: full Assessment and Findings, same rules as any stack.
- **Generate** for a Node unit: produce the Assessment, then stop for that unit with
  "Node.js generation is not supported in v1" and the recommended design in the Report.
- **Extend** an existing pipeline that already builds and deploys the Node unit:
  allowed when the change only mirrors existing jobs (e.g. a QA deploy job copied from
  DEV with different variables) and adds no new Node build logic. Anything more ->
  stop with the recommendation.
- In a monorepo, .NET units proceed normally; only Node units stop.
