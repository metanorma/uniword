# 02 — HTTP API + Docker

**Status:** PLANNED (Tier 3)
**Priority:** High for non-Ruby audience
**Depends on:** nothing

## Why

Currently uniword is a Ruby gem. That locks out every Python shop,
every Node shop, every Java shop, every internal tool that isn't
Ruby. A `uniword serve` command wrapping the CLI surface as REST,
shipped as an official Docker image, unlocks the entire non-Ruby
world.

## Approach

- New `uniword serve` CLI command (Roda or Sinatra)
- Endpoints: `/convert`, `/verify`, `/repair`, `/find-replace`,
  `/diff`, `/info`, `/metadata`
- Docker image: `metanorma/uniword:latest`
- OpenAPI spec at `/openapi.json`

## Why Tier 3

- Adds deployment surface (server security, auth, rate limiting)
- Requires SRE/ops investment
- Native clients (Python, Node — Tier 3/04, 05) may be a better
  fit for some use cases

## When to promote

When 2+ enterprise users ask "can I call this from a non-Ruby
service?" in the same quarter.
