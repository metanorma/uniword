# 08 — Cleanups: orphaned classes, dead code, DocumentRoot size

Status: DONE
Priority: P2
Absorbs: leftovers noted in TODO.validate/07 and /10 completion notes

## Context

Small debts recorded during the wave:
1. `Wordprocessingml::Ind` and `Tab` (numbering_elements.rb) became
   unreferenced when `w:lvl`'s invalid direct children were removed
   (TODO.validate/07). Public-API risk must be weighed before deleting.
2. `Ooxml::Relationships::ImageRelationship` carries an unreachable
   random-id default (noted in TODO.validate/10's notes as dead code
   referenced only by schema config).
3. `DocumentRoot` is at 571 lines and creeping toward the 700-line
   guideline; the theme/styles/scheme apply-family methods
   (apply_theme*, apply_styleset, apply_font_scheme, apply_color_scheme,
   apply_page_setup, replace_font, rename_style, remove_style*) are a
   coherent "document styling" cluster that could extract into a
   module (DocumentRoot stays the document model).

## Goal

1. Delete `Ind`/`Tab` (and their autoloads) after a grep proves zero
   references in lib and spec; if any consumer exists, keep and
   document instead.
2. Remove the dead random-id default from `ImageRelationship` (or
   justify and document why it stays, in its completion notes).
3. Extract the styling cluster from `DocumentRoot` into
   `Wordprocessingml::DocumentStyling` (module, included) — public
   method signatures unchanged.

## Design constraints

- Same forbidden-construct and autoload rules; new module autoloaded
  in the immediate parent namespace file.
- Behavior-neutral: no semantic changes, only relocation/deletion of
  proven-dead code.

## Acceptance

- Grep proofs attached in completion notes (Ind/Tab zero refs;
  ImageRelationship default unreachable).
- DocumentRoot back under 500 lines; suites
  `spec/uniword/wordprocessingml/ spec/uniword/builder/
  spec/uniword/docx/` green.
- RuboCop: no new offenses.

## Completion notes

Completed 2026-07-19.

1. **Orphaned classes** — grep proved zero references in lib and spec
   for `Wordprocessingml::Ind` (numbering_elements.rb) and
   `Wordprocessingml::Tabs` (level.rb — class already deleted in
   TODO.validate/07's w:lvl fix; only its autoload remained). Deleted
   the Ind class and both autoloads from wordprocessingml.rb.
   `Wordprocessingml::Tab` (tab.rb) is NOT orphaned (Builder +
   specs) — kept.
2. **ImageRelationship** — the unreachable `SecureRandom.hex(4)` rId
   default is removed; `id:` is now a required parameter (single rId
   authority: Docx::IdAllocator). The class stays for the
   config/ooxml/schemas/relationships.yml mapping (generation-time
   reference). Separately noted: `Image.from_data`'s
   `"temp_#{SecureRandom.hex(8)}"` relationship_id is a placeholder
   overwritten at registration time (never emitted) — left as-is,
   documented here.
3. **DocumentRoot styling cluster** — extracted to
   `Wordprocessingml::DocumentStyling` (new module, autoloaded in
   wordprocessingml.rb, included in DocumentRoot): apply_theme*,
   apply_styleset, apply_font_scheme, apply_color_scheme,
   apply_page_setup, replace_font, rename_style, remove_style,
   remove_unused_styles, auto_transition_theme, apply_*_from,
   apply_template, ensure_theme!. Public signatures unchanged.
   DocumentRoot: 596 → 380 lines.
   `DocumentRoot#remove_style` now returns the removed style or nil
   (was Boolean), matching rename_style's API shape.

### Verification

- `spec/uniword/wordprocessingml/ spec/uniword/builder/
  spec/uniword/docx/ spec/uniword/cli/` — 1597 examples, 0 failures.
- RuboCop net: document_root 13→5, document_styling 2 (pre-existing
  apply_theme ABC + apply_page_setup param list, relocated verbatim);
  numbering_elements/image_relationship clean; autoload resolution
  smoke via ruby -e (apply_font_scheme/apply_page_setup/rename_style
  through the module).
