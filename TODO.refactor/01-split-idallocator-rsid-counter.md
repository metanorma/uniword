# 01 — Split shared counter between para_id and rsid in IdAllocator

**Priority:** Critical (correctness)
**Files:** `lib/uniword/docx/id_allocator.rb`, `spec/uniword/docx/id_allocator_spec.rb`

## Problem

`IdAllocator#alloc_para_id` and `IdAllocator#alloc_rsid` share a single
`@para_counter` (lines 78–84). Each call advances the same counter:

```ruby
def alloc_para_id
  @para_counter += 1
  Digest::SHA256.hexdigest("para:#{@para_counter}").upcase[0, 8]
end

def alloc_rsid
  Digest::SHA256.hexdigest("rsid:#{@para_counter}").upcase[0, 8]
end
```

`alloc_rsid` does NOT increment — it reads whatever value `alloc_para_id`
last wrote. The result is order-dependent: the rsid produced for a table
row depends on how many paragraphs were allocated before it. Two
identical documents constructed via different call sequences produce
different rsids, breaking determinism (the whole purpose of this branch).

## Root cause

Variable name `@para_counter` reflects only one of two concerns sharing
it. The class comment claims "every builder, the adapter, and the
reconciler call into this class" for IDs — but the counters conflate
paragraph-IDs and revision-session-IDs.

## Fix

Split into two independent counters:

```ruby
def initialize
  # ...
  @para_counter = 0
  @rsid_counter = 0
end

def alloc_para_id
  @para_counter += 1
  Digest::SHA256.hexdigest("para:#{@para_counter}").upcase[0, 12]
end

def alloc_rsid
  @rsid_counter += 1
  Digest::SHA256.hexdigest("rsid:#{@rsid_counter}").upcase[0, 12]
end
```

Note the truncation bump to 12 hex chars — see `02-bump-sha-truncation.md`.

### Verification

Spec must assert: calling `alloc_para_id` 5 times produces IDs derived
ONLY from para counter, and `alloc_rsid` 5 times produces IDs derived
ONLY from rsid counter, regardless of interleaving.
