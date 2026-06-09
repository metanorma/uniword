# 016: Hyperlink reconciliation guards against non-rId IDs

## Status: DONE

## Summary

`reconcile_hyperlink_references` now only strips hyperlinks where `id`
matches the OOXML rId pattern (`rId\d+`). Non-rId values (like raw URLs
from the Builder API) are preserved because they may be wired later by
the serialization layer.

## Why

The Builder's `hyperlink` factory sets `id` to the raw URL string
(e.g., `"https://example.com"`). The OOXML spec requires `r:id` to be a
relationship ID, but the Builder defers relationship creation to
serialization. Without the guard, the reconciler was stripping all
builder-created hyperlinks.

## Change

Added `next false unless hl.id.match?(/\ArId\d+\z/i)` — only hyperlinks
with rId-pattern IDs are validated against document_rels.

## Files
- `lib/uniword/docx/reconciler/referential_integrity.rb`
- `spec/uniword/docx/reconciler_spec.rb`
