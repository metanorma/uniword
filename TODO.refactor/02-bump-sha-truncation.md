# 02 — Bump SHA256 truncation from 8 to 12 hex chars

**Priority:** Critical (collision risk)
**Files:** `lib/uniword/docx/id_allocator.rb`, `lib/uniword/builder/deterministic_id.rb`

## Problem

`alloc_para_id` and `alloc_rsid` truncate SHA256 output to 8 hex chars
(32 bits of entropy):

```ruby
Digest::SHA256.hexdigest("para:#{@para_counter}").upcase[0, 8]
```

Birthday paradox: ~50% collision probability at √(2^32) ≈ 65,536 unique
inputs. A long document (500 pages with paragraphs + tables + sections +
rsids across all parts) can approach this.

## Root cause

8 hex chars was a readability choice, not a safety choice. The cost of
4 more chars (48 bits, ~16M inputs before 50% collision) is negligible.

## Fix

Bump truncation to 12 hex chars everywhere SHA-truncated IDs are
generated:

- `lib/uniword/docx/id_allocator.rb` — `alloc_para_id`, `alloc_rsid`
- `lib/uniword/builder/deterministic_id.rb` — verify truncation length
  in `deterministic_id` if any

### Verification

Existing documents will get new IDs (different from previously
generated). This is expected and the right call — deterministic output
across runs is preserved (same input → same output), but specific values
will change. Fixture DOCX files will need regeneration.
