# 003: Deduplicate reconciler methods

## Status: DONE

## DRY violations fixed

### 3a. ensure_minimal_fill_list / ensure_minimal_bg_fill_list
Identical logic differing only in target attribute (fill_style_lst vs bg_fill_style_lst).
Extract shared `ensure_minimal_solid_fills` helper that accepts list class and current list.

### 3b. backfill_part_paragraphs / backfill_note_paragraphs
Identical body: strip_empty_runs, rsid_r, rsid_r_default, para_id, text_id.
Extract shared `backfill_paragraphs(paragraphs, rsid, id_seed)`.

### 3c. reconcile_footnotes / reconcile_endnotes
Structurally identical differing only in attr names and type.
Extract shared `finalize_notes` for the common post-processing.
Keep thin wrappers for type-specific dispatch.

### 3d. Remove respond_to? guards
All guarded objects are known types (Paragraph, Header, Footer, etc.) that
always have the queried methods via lutaml-model `initialize_empty: true` collections.

### 3e. Replace public_send with explicit case dispatch
`run.public_send(ref_attr)` replaced with `run.footnote_reference`/`run.endnote_reference`
via case statement — explicit typing, no dynamic dispatch.

## Files
- `lib/uniword/docx/reconciler.rb`
