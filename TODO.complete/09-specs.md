# 09 — Specs

**Status:** COMPLETED
**Priority:** High
**Depends on:** all implementation items

## New spec files

### `spec/uniword/content_types/types_spec.rb`

Unit tests for `Types#content_type_for`:

- Override wins over Default
- Default used when no Override
- Returns nil for unknown extension
- Returns nil for path with no extension

### `spec/uniword/docx/stripped_part_spec.rb`

Value object tests:

- Constructs with path + reason
- Readers return values
- Equality by path + reason

### `spec/uniword/docx/junk_classifier_spec.rb`

Unit tests for the classifier with synthetic content types + rels:

- Returns nil when Override matches
- Returns nil when Default extension matches
- Returns nil when path is targeted by a relationship
- Returns reason when no content type and no rel
- Returns reason for `[trash]/foo.dat`
- Returns reason for `__MACOSX/foo` (even with a matching Default)
- Returns reason for `.DS_Store`, `Thumbs.db`, `._foo`, `~$lock`
- Returns nil for legitimate unmodelled paths like `docProps/meta.xml`
  when the source declares an Override

### `spec/uniword/docx/raw_part_loader_policy_spec.rb`

Integration tests for the policy via a fixture with `[trash]/junk.dat`:

- Default mode (`:strip`):
  - `package.raw_parts` does NOT include `[trash]/junk.dat`
  - `package.stripped_parts` includes it with the right reason
  - Output ZIP does not contain `[trash]/junk.dat`
  - `package.to_zip_content(validate: true)` raises no issues
- Strict mode (`:raise`):
  - `package.raw_parts` includes `[trash]/junk.dat` with nil content_type
  - `package.to_zip_content(validate: true)` raises `ValidationError`
    with OPC-005 issues
- Legitimate unmodelled parts (`docProps/meta.xml` in the same fixture)
  are preserved in BOTH modes

### `spec/uniword/configuration_spec.rb` (extend)

- Default `on_noncompliant_content` is `:strip`
- Setter accepts `:strip` and `:raise` (and string forms)
- Setter raises `ArgumentError` for invalid values
- `reset!` restores `:strip`

## Updated spec files

### `spec/uniword/docx/package_raw_part_passthrough_spec.rb`

Replace the octet-stream test (lines 203-246) with strip assertions
as described in TODO.complete/07.

## Test fixture

The existing `add_undeclared_part` helper in
`package_raw_part_passthrough_spec.rb` already constructs a package
with `[trash]/0000.dat`. Reuse it; do not duplicate.

For an additional fixture exercising legitimate unmodelled parts,
the existing `spec/fixtures/docx_gem/no_styles.docx` (which carries
`docProps/meta.xml`) is the canonical source.

## Pattern: no doubles

All new specs use real model instances per the project rule. The
synthetic content types in the classifier spec use real
`ContentTypes::Types`, `Default`, `Override` instances — never
`double()`.
