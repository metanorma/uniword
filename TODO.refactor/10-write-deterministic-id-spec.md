# 10 — Write `spec/uniword/builder/deterministic_id_spec.rb`

**Priority:** High (spec gap)
**Files:** New `spec/uniword/builder/deterministic_id_spec.rb`

## Problem

`lib/uniword/builder/deterministic_id.rb` is a shared module included
in `ImageBuilder` and `ChartBuilder`. It has zero direct test coverage
— only exercised when image/chart builders run.

## Required coverage

### `deterministic_id(*seeds)`
- Returns deterministic hash from a single seed
- Returns deterministic hash from multiple seeds
- Same input → same output (across runs, across processes)
- Different inputs → different outputs
- Truncation length matches other ID generators (12 hex after fix 02)
- Format: uppercase hex string

### Determinism across process restarts
- Run in subprocess, capture output; run again, compare. Must match.

### Module inclusion
- `ImageBuilder` includes the module and exposes `deterministic_id`
- `ChartBuilder` includes the module and exposes `deterministic_id`

## Approach

Spec the module in isolation by including it in a small test class:

```ruby
class TestSubject
  include Uniword::Builder::DeterministicId
end
```

Use real string seeds; no doubles.
