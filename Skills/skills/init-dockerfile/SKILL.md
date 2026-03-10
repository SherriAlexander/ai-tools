---
name: init-dockerfile
description: Initialize Dockerfile best practices
---

# Initialize Dockerfile Best Practices

Add Docker/Dockerfile best practices. **Follow `~/.copilot/skills/init-conventions/SKILL.md` for standard file handling.**

## Target File

`.github/instructions/dockerfile.instructions.md`

## Path Pattern

`**/Dockerfile*,**/docker-compose*.{yml,yaml},.dockerignore`

## Content

<!-- RULES_START -->
---
applyTo: "**/Dockerfile*,**/docker-compose*.{yml,yaml},.dockerignore"
---

# Dockerfile Rules

## Layer Architecture

Docker images use stacked read-only layers (OverlayFS). Only `RUN`, `COPY`, and `ADD` create layers. **Once any layer changes, all subsequent layers rebuild**—instruction ordering is critical.

### Layer Optimization

Order instructions from least to most frequently changing:

```dockerfile
# Dependencies change less often than source code
COPY package*.json ./
RUN npm ci
COPY . .                    # Source changes don't invalidate dependency cache
```

**Cleanup must occur in the same layer as installation**—deleting files in a subsequent layer doesn't reduce image size:

```dockerfile
# ✅ Cleanup in same instruction reduces actual layer size
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*
```

## Multi-Stage Builds

Separate build tools from runtime images:

```dockerfile
FROM golang:1.24 AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app

FROM gcr.io/distroless/static-debian12
COPY --from=build /app /app
CMD ["/app"]
```

For interpreted languages:

```dockerfile
FROM python:3.12 AS builder
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM python:3.12-slim
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*
```

## Base Image Selection

| Image Type | Size | Notes |
|------------|------|-------|
| Alpine | ~5 MB | musl libc—watch for compatibility issues |
| Debian/Ubuntu slim | ~50-80 MB | Full glibc, excellent compatibility |
| Distroless | ~2-32 MB | No shell, maximum security |
| Scratch | 0 MB | Static binaries only |

**Alpine's musl libc** causes DNS resolution issues, glibc binary incompatibility, and smaller thread stacks. Prefer `-slim` variants for compatibility.

**Distroless** (e.g., `gcr.io/distroless/static-debian12`) offers glibc compatibility without shell access.

## Dockerfile Structure

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-slim                       # Pinned version, slim variant
LABEL maintainer="team@example.com"
ENV NODE_ENV=production
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./                   # Dependency manifests first
RUN npm ci --only=production

COPY . .                                # Source code last

RUN groupadd -r app && useradd -r -g app app
USER app                                # Non-root user

EXPOSE 3000
CMD ["node", "server.js"]               # Exec form for signal handling
```

## COPY vs ADD

- **COPY**: Default choice—explicit and predictable
- **ADD**: Only for tar extraction (`ADD rootfs.tar.gz /`) or URL fetching

For downloads, use `RUN` with `curl` for better control.

## ENTRYPOINT vs CMD

Always use **exec form** (JSON array) for proper signal handling:

```dockerfile
ENTRYPOINT ["python", "/app/main.py"]   # Fixed executable
CMD ["--config=/defaults.json"]         # Default arguments, overridable
```

## BuildKit Optimizations

Cache mounts persist package caches without including in final image:

```dockerfile
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y python3
```

Parallel stage execution:

```dockerfile
FROM node:20-slim AS frontend
RUN npm ci && npm run build

FROM python:3.11-slim AS backend        # Builds in parallel
RUN pip install -r requirements.txt

FROM nginx:alpine
COPY --from=frontend /app/dist /usr/share/nginx/html
COPY --from=backend /app /api
```

## Version Pinning

| Strategy | Example | Reproducibility |
|----------|---------|-----------------|
| Major.minor | `python:3.11` | Medium (auto patches) |
| Full version | `python:3.11.5-slim` | High |
| Digest | `python:3.11@sha256:abc...` | Maximum |

Use major.minor for development, full version or digest for production.

## .dockerignore

Always include to prevent bloated build contexts:

```dockerignore
.git
node_modules
__pycache__
*.pyc
.env*
tests/
docs/
*.md
.vscode/
.idea/
coverage/
dist/
build/
```

### Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `:latest` tag | Pin to specific versions (`python:3.11-slim`) |
| Running as root | Create user: `RUN useradd -r app` then `USER app` |
| Installing recommended packages | Use `--no-install-recommends` |
| Cleanup in separate layer | Combine install and cleanup in single `RUN` |
| Large build context | Use comprehensive `.dockerignore` |
| Shell form for CMD/ENTRYPOINT | Use exec form `["cmd", "arg"]` for signal handling |
| Copying everything before deps | Copy dependency files first, then `npm ci`, then source |

### Quick Reference

```dockerfile
# Multi-stage with non-root user
FROM node:20-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-slim
WORKDIR /app
RUN groupadd -r app && useradd -r -g app app
COPY --from=build --chown=app:app /app/dist ./dist
COPY --from=build --chown=app:app /app/node_modules ./node_modules
USER app
EXPOSE 3000
CMD ["node", "dist/server.js"]
```
<!-- RULES_END -->
