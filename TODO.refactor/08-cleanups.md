# 08 — Cleanups: orphaned classes, dead code, DocumentRoot size

Status: PENDING
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
