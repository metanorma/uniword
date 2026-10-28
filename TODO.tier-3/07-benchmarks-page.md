# 07 — Benchmarks page

**Status:** PLANNED (Tier 3)
**Priority:** Marketing/credibility
**Depends on:** nothing

## Why

Show uniword vs python-docx vs docx4j vs LibreOffice on speed,
memory, fidelity, verification depth. Living page that re-runs on
each release.

## Approach

- Benchmark suite under `benchmarks/`
- GitHub Actions workflow runs benchmarks on each release
- Results published to a GitHub Pages site

## Why Tier 3

Fair benchmarks are hard; risk of gaming. Better to ship after core
features are solid.
