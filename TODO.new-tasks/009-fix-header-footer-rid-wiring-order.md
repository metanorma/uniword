# 009: Fix header/footer rId wiring order — reconciler must run after all IDs are assigned

## Status: DONE

## Problem

The `to_zip_content` flow is:

```
1. Reconciler.new(self).reconcile     ← verifies sectPr header/footer refs
2. inject_part_relationships(...)      ← assigns NEW rIds to headers/footers
3. serialize_package_parts(...)        ← writes XML
```

`inject_headers` in `PackageSerialization` calls `next_rid(document_rels)` to
generate brand-new rIds, then calls `wire_header_reference(type, r_id)` which
OVERWRITES the sectPr header reference rIds. This happens AFTER the reconciler
has already verified the OLD rIds.

This means:
- The reconciler validates rIds that will be immediately replaced
- If the reconciler removed a "dangling" rId that was actually going to be
  wired to a valid header, it causes data loss
- The final rIds in the output are never verified

## Fix

Option A (preferred): Assign rIds in the reconciler, not in serialization.
The reconciler should:
1. Build the document.xml.rels for headers/footers
2. Wire the sectPr references to those rIds
3. Then verify that all sectPr refs have matching rels

Option B: Move verification to a second reconciler pass after injection.

This is a medium-term refactor since it moves logic from PackageSerialization
into the Reconciler.

## Files
- `lib/uniword/docx/package_serialization.rb` (lines 264-307, 422-448)
- `lib/uniword/docx/reconciler/body.rb`
- `lib/uniword/docx/reconciler/package_structure.rb`
