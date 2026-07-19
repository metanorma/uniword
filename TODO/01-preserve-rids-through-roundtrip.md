# 14 — Preserve rIds through round-trip (load → save)

**Status: COMPLETED via TODO.validate/10** — `Docx::IdAllocator` is now
the single rId authority. `Package#prepare_allocator` seeds it from the
package's current rels before reconciliation, and the Reconciler's
preserve-first assembly keeps loaded rIds verbatim (only genuinely new
relationships get fresh allocations). The legacy renumbering path and
all out-of-band allocators (`next_available_rid`, serializer `next_rid`)
are gone. The 3 previously skipped `docx_roundtrip_spec.rb` examples
pass unskipped.

**Priority:** Medium (correctness gap)
**Files:** `lib/uniword/docx/reconciler/referential_integrity.rb`,
`lib/uniword/docx/id_allocator.rb`,
`spec/integration/docx_roundtrip_spec.rb`

## Problem

Round-trip tests (`spec/integration/docx_roundtrip_spec.rb`) were marked
`skip` because saved documents have different rId values than originals:

```
Expected: r:embed="rId8"
Actual:   r:embed="rId9"

Expected: r:id="rId10"
Actual:   r:id="rId12"
```

The reconciler's rId normalization assigns sequential rIds based on
insertion order during save, ignoring the rIds present in the loaded
document.

## Root cause

`IdAllocator#alloc_rid` registers rIds by `[target, type]` pair. When
the document is loaded, existing rels are seeded via `seed_from_rels`,
but the reconciler's referential-integrity pass then REBUILDS rels
from the allocator's view rather than preserving originals. Insertion
order during rebuild differs from the original DOCX's order, producing
different rId numbers.

## Fix approach

The reconciler should preserve existing rIds when the (target, type)
pair matches a loaded rel. Only allocate fresh rIds for genuinely new
content (e.g., builder-added hyperlinks/images).

Two possible strategies:

1. **Preserve-first rebuild**: in `reconcile_document_rels` (package_structure.rb),
iterate existing document_rels first and re-use their rIds, then
allocate new rIds for any new content.

2. **rId-stable allocator mode**: add an allocator flag
`preserve_existing: true` that, when set, returns the loaded rId for
any (target, type) match before falling back to allocation.

Strategy 1 is simpler and lives in one place.

## Verification

Unskip the 3 tests in `docx_roundtrip_spec.rb` that mention this TODO.
They should pass once rIds are preserved through round-trip.

## Related

This gap was exposed by the audit branch's CI runs but is not caused
by the audit work — the behavior predates it.
