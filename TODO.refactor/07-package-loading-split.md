# 07 — Package::Loading split (package.rb back under the size guideline)

Status: PENDING
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
