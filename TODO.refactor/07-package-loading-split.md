# 07 — Package::Loading split (package.rb back under the size guideline)

Status: DONE
Priority: P2
Depends on: 01 (registry-driven load shrinks the load code first)
Absorbs: none (new)

## Context

`lib/uniword/docx/package.rb` is 734 lines — over the project's
700-line guideline. After item 01 makes loading registry-driven, the
remaining file still mixes: package state/attributes, zip reading
(binary extraction), part extraction helpers
(extract_header_footer_parts, extract_image_parts, extract_theme_media),
save orchestration (to_file/to_zip_content), and the integrity gate.

## Goal

- Extract loading into `Docx::PackageLoading` (module or
  collaborating class): zip reading, registry-driven part loading,
  extraction helpers.
- `Package` keeps: state, save orchestration, the gate, applied_fixes.
- Preserve the public surface (`from_file`, `from_zip_content`,
  `read_binary_from_zip`) — delegators on Package if external callers
  use them (grep first).

## Design constraints

- Do this AFTER 01 so the move is mostly delete-and-point, not a
  rewrite of procedural code.
- Same forbidden-construct and autoload rules; new file autoloaded in
  `lib/uniword/docx.rb`.
- Keep `Package` under 400 lines and every method under the
  guidelines (50 lines).

## Acceptance

- package.rb ≤ 400 lines; loading lives in its own file.
- `bundle exec rspec spec/uniword/docx/ spec/integration/
  docx_roundtrip_spec.rb` green; `bundle exec exe/uniword help` OK.
- RuboCop: no new offenses.

## Completion notes

Completed 2026-07-19 — premise consumed by item 01; no further code
change was needed.

Item 01 (registry-driven bidirectional loading) already performed the
split this item called for: loading lives in `Docx::PartLoader` and
its strategy classes (`lib/uniword/docx/part_loader/`), and
`Package.from_zip_content` is a 4-line delegation. Verified the
acceptance criteria against the current tree:

- `lib/uniword/docx/package.rb` is **354 lines** (was 734) — well
  under the ≤400 target.
- Loading (ZIP reading, registry-driven part loading, binary
  re-extraction via `read_binary_from_zip` in
  `part_loader/image_loader.rb`) is entirely outside package.rb.
- Longest method: 50 lines (custom_xml_items= writer, at the
  boundary).
- Public surface preserved: `Package.from_file`,
  `Package.from_zip_content`, `Package.to_file`; binary re-extraction
  is internal to the loader (grep showed no external callers of the
  old `Package.read_binary_from_zip`).
- `spec/uniword/docx/` — 352 examples, 0 failures;
  `exe/uniword help` OK; no touched files, no RuboCop delta.
