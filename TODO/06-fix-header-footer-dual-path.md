# 012: Fix header/footer dual-path ambiguity

## Status: COMPLETED via TODO.validate/09

`header_footer_parts` is now the single storage path: a
`Docx::HeaderFooterPartCollection` of `HeaderFooterPart` value objects
populated identically by the loader (with original rIds/targets and
sectPr-derived types) and by the Builder (`document.headers`/`footers`
are delegating views over the same store with upsert-by-type semantics).
Duplicate rels, overwritten sectPr rIds and duplicate content-type
overrides are impossible by construction; the serializer-side dual
injection was deleted. See `TODO.validate/09-model-driven-package-parts.md`
completion notes.

## Problem

Headers and footers have two completely separate storage mechanisms:

1. **Builder API path**: `document.headers` / `document.footers` (Hash of
   type → Header/Footer objects, used when building documents from code)
2. **Round-trip path**: `document.header_footer_parts` (Array of hashes
   with `{r_id:, target:, rel_type:, content_type:, content:}`, used when
   loading existing DOCX files)

Both paths inject into `document.xml.rels` during serialization via
`inject_headers` + `inject_header_footer_parts`. This creates two issues:

### Issue 1: Potential duplicate rels
If a document has BOTH `document.headers` (builder path) AND
`document.header_footer_parts` (round-trip path), two sets of header/footer
rels are injected. There's no deduplication between them.

### Issue 2: rId mismatch in sectPr
The builder path (`inject_headers`) calls `wire_header_reference` which
OVERWRITES sectPr rIds with new values. But `header_footer_parts` preserves
the original rIds from the loaded DOCX. If both exist, the builder path wins
and the round-trip path's rIds become dangling.

### Issue 3: Content type duplication
Both `inject_headers` and `inject_header_footer_parts` add content type
overrides for `header*.xml` / `footer*.xml`. No deduplication check exists.

## Fix

Unify both paths into a single canonical representation:

1. During `from_zip_content`, convert `header_footer_parts` into the
   `document.headers`/`document.footers` Hash format
2. Add rId metadata to the Hash entries so `wire_header_reference` can
   preserve existing rIds
3. Remove `header_footer_parts` array and `inject_header_footer_parts`
4. Single injection path in `PackageSerialization`

This is a medium-term refactor because it changes the round-trip loading
contract.

## Files
- `lib/uniword/docx/package.rb` (line 286, `extract_header_footer_parts`)
- `lib/uniword/docx/package_serialization.rb` (lines 264-330, 472-479)
- `lib/uniword/wordprocessingml/document_root.rb` (line 103)
- `lib/uniword/docx/reconciler/body.rb` (line 62)
