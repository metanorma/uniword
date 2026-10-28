# 04 — Python bindings

**Status:** PLANNED (Tier 3)
**Priority:** Audience expansion
**Depends on:** nothing

## Why

Python is the dominant data/scripting language. Data science,
academia, ops — all Python-heavy. Bindings unlock that audience.

## Approach

Two options:
1. **PyCall/Fiddle**: Ruby stays the source of truth, Python calls
   in via PyCall.rb reversed. Complex setup.
2. **HTTP client**: Python library that wraps the HTTP API
   (Tier 3/02). Cleanest separation.

Recommend option 2 once HTTP API lands.

## Why Tier 3

- Cross-language maintenance burden
- Better as a separate repo: `uniword-python`
- Depends on HTTP API (Tier 3/02)
