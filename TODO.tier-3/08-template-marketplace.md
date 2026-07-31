# 08 — Template marketplace

**Status:** PLANNED (Tier 3)
**Priority:** Community building
**Depends on:** nothing

## Why

A separate `uniword-resources` repo where users publish open-source
StyleSets, themes, templates. `uniword theme install <name>` from a
remote registry. Builds community.

## Approach

- GitHub repo: `metanorma/uniword-resources`
- Convention: each resource is a directory with metadata.yml + content
- CLI: `uniword theme install <name>`, `uniword theme search <query>`
- Index built via GitHub Actions

## Why Tier 3

Community infra requires moderation, governance.
