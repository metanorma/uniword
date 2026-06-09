# 017: Fix run consolidation rsid regression (round-trip content loss)

## Status: DONE

## Problem

`Reconciler::Helpers#consolidate_runs` merges adjacent runs with identical
`RunProperties` (formatting). But it ignores Run-level attributes (`rsid_r`,
`rsid_r_pr`) that distinguish runs created at different revision points.

The `run_properties_match?` check only compares `a.properties.to_xml ==
b.properties.to_xml` — it never looks at the Run's own `rsid_r` or `rsid_r_pr`.

This causes **content loss** during round-trip: the reconciler merges runs that
should remain separate because they have different revision tracking:

```
Original: <w:r rsidRPr="005F0FA3"><w:t>"Excellence is not a destination</w:t></w:r>
          <w:r rsidRPr="005F0FA3"><w:t>. (Quotation style)</w:t></w:r>
          <w:r rsidRPr="005F0FA3"><w:t>"</w:t></w:r>

Round-trip: <w:r><w:t>"Excellence is not a destination. (Quotation style)"</w:t></w:r>
```

The original had 3 separate runs with potentially different `rsidR` values.
After consolidation, they become 1 run — losing revision tracking granularity.

### Failing tests

- `spec/uniword/docx/package_roundtrip_spec.rb[1:9:1]` — document.xml
  round-trip (10 diffs, all from run consolidation)
- `spec/uniword/docx/package_roundtrip_spec.rb[1:10:1]` — styles.xml
  round-trip (likely cascading)

## Fix

**Option A (recommended):** Only consolidate runs during builder construction
(not during reconciliation). The reconciler's job is to FIX inconsistencies,
not to optimize document structure. Run consolidation changes semantics.

**Option B:** Add rsid checks to `can_merge?`:
```ruby
def can_merge?(prev, current)
  return false unless text_only_run?(prev) && text_only_run?(current)
  return false if prev.rsid_r && current.rsid_r && prev.rsid_r != current.rsid_r
  return false if prev.rsid_r_pr && current.rsid_r_pr && prev.rsid_r_pr != current.rsid_r_pr
  true
end
```

Option A is preferred because consolidation is a builder concern, not a
reconciliation concern. The reconciler should preserve document fidelity.

## Files
- `lib/uniword/docx/reconciler/helpers.rb` (line 221, `consolidate_runs_in_body`)
- `lib/uniword/docx/reconciler/parts.rb` (line 292, call site)
