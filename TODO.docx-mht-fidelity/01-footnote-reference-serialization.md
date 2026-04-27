# 01 - Footnote Reference Serialization in MHTML Body

## Status: DONE

## Problem

When the OOXML → MHTML Transformer converts a DocxPackage with footnote references, runs containing `footnoteReference` elements are silently dropped. The generated MHTML body has **0 footnote reference markers** where the reference rice.doc has **5** (3 `MsoFootnoteReference` spans + footnote body paragraphs).

## Fix

`lib/uniword/transformation/mhtml_element_renderer.rb`:
- `run_to_html` (line 78-79): Early return for `footnote_reference` and `endnote_reference` runs
- `footnote_reference_to_html` (line 132): Renders `<span class="MsoFootnoteReference"><span style="mso-special-character:footnote"></span></span>`
- `endnote_reference_to_html` (line 137): Renders equivalent endnote HTML

## Tests

`spec/transformation/mhtml_element_renderer_spec.rb`:
- "renders footnote reference as MsoFootnoteReference span"
- "renders footnote reference as empty span structure"
- "renders endnote reference as MsoEndnoteReference span"
- "renders footnote reference in paragraph content"
