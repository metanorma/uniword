# 05 — lutaml-model memory leak investigation write-up

**Status:** COMPLETED (this PR; mitigation in same PR)
**Priority:** High
**Depends on:** nothing

(See `01-lutaml-model-memory-leak.md` for the full design.)

This file tracks what was actually done in this PR.

## What's in this PR

1. **Investigation write-up** in
   `TODO.tier-1/01-lutaml-model-memory-leak.md` — root-cause
   hypothesis, two-track fix plan, verification recipe.
2. **Memory profile spec** at `spec/performance/memory_profile_spec.rb`
   that confirms the leak with `memory_profiler`. Runs as a
   standalone profile (`bundle exec rspec spec/performance/`),
   excluded from the default suite to avoid the OOM trap.
3. **`Configuration#gc_aggressive_mode`** flag (default false). When
   true, the loader and reconciler call `GC.start` between major
   phases. Lets batch pipelines trade throughput for memory.
4. **`DocumentFactory.from_file(path, gc: true)`** shortcut that
   wraps the load in `GC.start` before and after — for one-off large
   documents.

## What's NOT in this PR

- The actual upstream fix in `lutaml-model`. That's a separate PR to
  a separate repo. This PR's investigation writes the spec and
  proposal that PR will reference.
- Streaming writer (Tier 2, `TODO.tier-2/05-streaming-writer.md`).
- Cross-run `find-replace` (out of scope for the v1 find-replace).

## Verification

```bash
bundle exec rspec spec/performance/memory_profile_spec.rb
# Prints retained counts + recommends upstream fix
```
