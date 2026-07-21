# 10 — Docs and CHANGELOG

**Status:** COMPLETED
**Priority:** Medium
**Depends on:** all implementation items

## Pages to update

### `docs/_guides/round-trip-fidelity.adoc`

The "Unmodelled parts: byte-for-byte preservation" section currently
says "anything uniword doesn't model is preserved verbatim". This is
no longer the whole truth. Add a subsection:

```asciidoc
== Exception: non-compliant parts are stripped at load

The byte-for-byte preservation promise covers *legitimate* unmodelled
parts — those with a content type declaration (Override or Default
extension) in `[Content_Types].xml`. Parts with no declaration, and no
incoming relationship, are stripped at load:

* `[trash]/*.dat` and similar junk drawers Word and other producers
  leave inside the ZIP
* OS artifacts (`__MACOSX/`, `.DS_Store`, `Thumbs.db`, `._*`, `~$*`)

This matches Word's own behavior: Word ignores such parts on open and
does not write them on save.

[cols="2,4"]
|===
| Configuration | Behavior

| `on_noncompliant_content = :strip` (default)
| Strip silently. Populate `package.stripped_parts`. Save succeeds.

| `on_noncompliant_content = :raise`
| Don't strip. The write-time integrity gate raises
  `Uniword::ValidationError` with structured OPC-005 issues.
|===

The strips are visible three ways:

. `Package#stripped_parts` — `Array<StrippedPart>` (path + reason)
. `Uniword.configuration.log_save_fixes = true` — INFO log per strip
. `uniword verify` on the source — still reports OPC-005 (verify reads
  the ZIP directly; it doesn't go through the loader). Save applies
  cleanup; verify reports source state.
```

### `docs/_features/profiles.adoc` or a new `docs/_features/configuration.adoc`

If a configuration page exists, add the new option there. Otherwise,
add a brief mention in `docs/_interfaces/ruby-api.adoc`'s Configuration
section.

### `docs/_interfaces/cli.adoc`

Note that `uniword repair` reports strips alongside reconciler fixes.
(Once that CLI surface is wired, which is a follow-up; for now, the
strips are visible via the Ruby API and the log.)

### `CHANGELOG.md`

Add a new 1.4.2 entry under `[Unreleased]` (or replace it):

```markdown
## [1.4.2] - 2026-07-21

### Added

- `Configuration#on_noncompliant_content` policy knob (default
  `:strip`, alternative `:raise`). Controls what happens when a
  loaded package contains parts with no content type declaration.
- `Docx::JunkClassifier` — classifies a path as junk based on OS
  artifact patterns and the "no content type AND no incoming
  relationship" OPC rule.
- `Docx::StrippedPart` value object (path + reason) — the reporting
  record for stripped parts.
- `ContentTypes::Types#content_type_for(path)` — Override-then-Default
  lookup. Single source of truth for content type resolution.
- `Package#stripped_parts` — populated by the loader in `:strip` mode.

### Changed

- `Docx::RawPartLoader` now strips non-compliant parts at load by
  default (Word-identical behavior). Legitimate unmodelled parts
  (those with a content type declaration) continue to round-trip
  byte-for-byte per the 1.4.0 promise.

### Fixed

- Loading then saving a DOCX with `[trash]/*.dat` or other undeclared
  parts no longer fails with `OPC-005 No content type declared` at
  save. The junk is stripped at load and reported via
  `Package#stripped_parts`.

### Removed

- `FALLBACK_RAW_PART_CONTENT_TYPE` constant and the
  `application/octet-stream` fallback in
  `Docx::PackageSerialization#inject_raw_part_content_types`. The
  fallback preserved junk that Word would strip and masked genuinely
  missing declarations.
```
