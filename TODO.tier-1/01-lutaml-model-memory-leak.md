# 01 — lutaml-model memory leak

**Status:** IN PROGRESS (investigation + uniword-side mitigation)
**Priority:** High (blocks enterprise/server use)
**Branch:** TBD (multi-commit, likely two PRs: uniword mitigation + upstream lutaml fix)
**Upstream:** `lutaml/lutaml-model` at `/Users/mulgogi/src/lutaml/lutaml-model`

## Problem

CLAUDE.md already documents this in detail:

> Root cause: lutaml-model has a memory leak where
> `Lutaml::Model::Serializable` instances are never garbage-collected.
> Each DOCX load creates ~1200 retained objects per MB of DOCX
> content. Over 6781 examples, RSS grows past 8 GB and crashes.

Symptoms:
- Full test suite OOMs on a 8 GB runner
- Long-running server processes balloon RSS until killed
- Loading >20 MB DOCX files in a single call is unreliable
- CI runs 30-50 minutes per OS (much of it allocation/GC overhead)

## Root cause (hypothesis)

`Lutaml::Model::Serializable` likely retains instances in a class-level
collection (e.g., `@@instances`, `ObjectSpace::WeakMap` that isn't
weak, or `TracePoint` hooks that hold references). Every
`Serializable` subclass instance accumulates forever.

To confirm:
```bash
bundle exec ruby -e '
require "lutaml/model"
GC.start
before = ObjectSpace.each_object(Lutaml::Model::Serializable).count
1000.times { Class.new(Lutaml::Model::Serializable).new }
GC.start
after = ObjectSpace.each_object(Lutaml::Model::Serializable).count
puts "before=#{before} after=#{after} delta=#{after - before}"
'
```

If `delta == 1000`, the leak is confirmed.

## Two-track fix

### Track A: uniword-side mitigation (this repo)

Reduce the rate of `Serializable` instantiation and clear retained
state where possible.

**A1. Clear `element_order` arrays (already done).** The
spec_helper's `after(:each)` hook does this — reduces per-cycle
growth from ~7 MB to ~1 MB per the existing comment. Extend the same
pattern to other large transient state.

**A2. Lazy-load heavy parts.** `Docx::PartLoader` currently
instantiates every model the registry knows about. Make truly lazy:
load on first access via a proxy, not at `from_zip_content` time.

**A3. Document-scoped GC hook.** For programmatic use, expose
`Uniword::DocumentFactory.from_file(path, gc: true)` that wraps the
load in `GC.start(immediate: true)` and `GC.auto_compact = true` if
available. Lets batch pipelines explicitly request tighter GC.

**A4. Streaming writer for huge docs** (deferred to Tier 2 —
`TODO.tier-2/05-streaming-writer.md`). For the leak specifically, a
streaming writer that doesn't materialize the whole model would
sidestep the issue for the writing direction. Reading still leaks.

### Track B: upstream lutaml-model fix (separate repo)

The actual leak is in `Lutaml::Model::Serializable`. Fix:

**B1. Identify the retaining reference.** Likely candidates in
`/Users/mulgogi/src/lutaml/lutaml-model/lib/lutaml/model`:
- `serializable.rb` — class-level instance tracking
- `type.rb` — type registry holding instances
- `mapping.rb` — mapping dsl holding instance refs

**B2. Remove or weaken the reference.** Replace with `WeakRef` or
remove entirely if the tracking is for debugging only.

**B3. Add a `Lutaml::Model.clear_instances!` escape hatch.** Lets
long-running processes explicitly reset.

**B4. Benchmark with `memory_profiler`.** Add a benchmark spec to
lutaml-model that loads 1000 instances and asserts retained count
< some threshold.

## Verification

After both tracks:
```bash
bundle exec rspec --profile 30
```

RSS should stay under 2 GB across the full suite (vs 8+ GB today).
Test suite runtime should drop from ~30 min to <15 min per OS.

## Why this is Tier 1 #1

Every other Tier 1/2/3 item depends on the library being scalable.
- `find-replace` over a 50 MB DOCX → OOMs today
- `combine` (3-way merge) needs to load 3 docs → 3x the leak
- HTTP API long-running → leaks forever
- PDF export of a large doc → OOMs during render

Fix the leak first.

## What lands in this PR

The investigation write-up (this file expanded with actual
measurements), Track A items A1-A4, and a benchmark spec under
`spec/performance/memory_profile_spec.rb`. Track B (upstream
lutaml-model) is a separate PR to a separate repo.
