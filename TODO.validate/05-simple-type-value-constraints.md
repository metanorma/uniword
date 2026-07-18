# 05 — Value constraints on high-traffic OOXML simple types

Status: DONE
Priority: P0
Absorbs: none (new)

## Context

3,222 `attribute` declarations across lib; zero use of `values:`, `pattern:`,
`required:` — although lutaml-model 0.8.17 supports `values:` (raises
`InvalidValueError`) and `pattern:`. Verified: `Properties::Alignment`
accepts `"diagonal-garbage"`, `SharedTypes::HexColor` accepts
`"not-a-color"`, `TwipsMeasure` accepts `-9999`, and
`Ooxml::Types::OoxmlBoolean` passes unknown strings through unchanged
(`lib/uniword/ooxml/types/ooxml_boolean.rb:21`). Enum semantics exist only
in comments (e.g. `lib/uniword/properties/alignment.rb:8-14`).

## Goal

Constrain the highest-traffic simple types at their definition points in
`lib/uniword/shared_types/`, `lib/uniword/ooxml/types/`,
`lib/uniword/properties/`:

- `ST_Jc` (alignment) — full ECMA-376 enum incl. Word extensions
  (`thaiDistrib`, `kashidaLow`, etc.; take the full list from wml.xsd /
  ECMA-376, not the comment subset).
- `ST_Highlight`, `ST_Border` (border styles), `ST_ThemeColor` — enums.
- `ST_HexColor` — pattern: 6 hex digits or `auto`.
- Twips / unsigned-decimal measures — non-negative integers (reject
  negatives; define a shared constrained type, DRY).
- paraId / textId — 8-hex-digit pattern.
- `ST_OnOff` via `OoxmlBoolean` — accept OOXML spellings
  (true/false/1/0/on/off), raise on anything else instead of pass-through.

Generator: extend the schema model generator (under
`lib/uniword/ooxml/schema/`) to emit `values:`/`pattern:` when the YAML in
`config/ooxml/schemas/*.yml` carries the restriction; if the YAML lacks the
data, add it for the types in scope. If generator wiring proves infeasible
without a large change, document why in the completion notes (bounded
effort — the type constraints themselves are the deliverable).

## Watch out

- Round-trip parsing of real fixtures must not break: every value seen in
  `spec/fixtures` must be inside the enums (full ECMA lists).
- Check whether `values:` raises at assignment or at `validate!`; ensure
  Builder coercion paths and parsing still work. Run
  `spec/uniword/wordprocessingml/ spec/uniword/builder/ spec/uniword/docx/`.

## Acceptance

- Garbage values raise for each constrained type; valid values round-trip.
- Specs per constrained type (valid accepted, invalid rejected, serialized
  form unchanged); suites above green.
- Prefer editing existing type files; do NOT edit `lib/uniword.rb` this
  wave (another item owns it) — if a genuinely new type file is required,
  register its autoload in the nearest existing parent-namespace file and
  note it in completion notes.

## Completion notes

### How validation fires (lutaml-model 0.8.17, verified in gem source)

- `values:` and `pattern:` are checked **only** by `validate`/`validate!`
  (`Lutaml::Model::Attribute#validate_value!`); attribute setters and XML
  parsing never enforce them. Enum attributes additionally get a generated
  getter/setter and `value?`/`value`/`value=`/`value!` shorthand methods.
- `pattern:` is effectively unusable in 0.8.17 for optional attributes:
  `valid_pattern!` has no nil/uninitialized guard, so `validate!` raises a
  raw `TypeError` (`no implicit conversion of UninitializedClass into
  String`) when the attribute was never set.
- Type-level `cast` **does** fire on every assignment, on `initialize`,
  and during XML parsing (setter -> `Attribute#cast_value` ->
  `Type.cast`).

Chosen mechanism per constraint:

- **Enums -> `values:`** (validate!-time; round-trip parsing of
  out-of-enum values still works, garbage is rejected by
  `validate`/`validate!`): ST_Jc, ST_JcTable, ST_HighlightColor, ST_Border
  (full 193-value list), ST_ThemeColor, ST_VerticalAlignRun,
  ST_VerticalJc, ST_TabJc, ST_TextAlignment. All enumerations were taken
  verbatim from `data/schemas/iso/wml.xsd`.
- **Patterns/ranges -> Type `cast` overrides** (assignment- and
  parse-time, because `pattern:` is broken as noted and integers are not
  covered by `values:`/`pattern:`): ST_HexColor, ST_UnsignedDecimalNumber,
  w14:paraId/textId (ST_LongHexNumber), ST_OnOff.

### Constrained types (lib files)

- `lib/uniword/ooxml/types/ooxml_boolean.rb` — `cast`/`serialize` now
  accept the full ST_OnOff spellings (true/false/1/0/on/off) and raise
  `Lutaml::Model::Type::InvalidValueError` on anything else instead of
  passing through (the line-21 bug). Uninitialized values still pass
  through (required by lutaml-model internals); nil still casts to false.
- `lib/uniword/ooxml/types/ooxml_boolean_optional.rb` — same, with
  nil -> nil preserved.
- `lib/uniword/ooxml/types/hex_color_value.rb` (NEW) — `HexColorValue <
  Type::String`, raises on values other than `auto` or 6 hex digits.
- `lib/uniword/ooxml/types/theme_color_value.rb` (NEW) — `ThemeColorValue`
  carrying the full 17-value ST_ThemeColor enumeration as `VALUES`.
- `lib/uniword/ooxml/types/unsigned_decimal_number.rb` (NEW) —
  `UnsignedDecimalNumber < Type::Integer`, raises
  `Lutaml::Model::Type::MinBoundError` on negatives (DRY shared type for
  unsigned measures).
- Autoloads for the three new files registered in the existing parent
  namespace file `lib/uniword/ooxml/types.rb` (NOT lib/uniword.rb, per
  the wave rule).
- `lib/uniword/shared_types/hex_color.rb` — `val` now typed
  `Ooxml::Types::HexColorValue`.
- `lib/uniword/shared_types/twips_measure.rb`, `point_measure.rb`,
  `pixel_measure.rb` — `val` now typed
  `Ooxml::Types::UnsignedDecimalNumber` (ST_TwipsMeasure,
  ST_PointMeasure, ST_PixelsMeasure are all based on
  ST_UnsignedDecimalNumber).
- `lib/uniword/shared_types/text_alignment.rb` — `values:` with the
  5-value ST_TextAlignment enumeration.
- `lib/uniword/properties/alignment.rb` — `AlignmentValue::VALUES` =
  full 12-value ST_Jc (incl. mediumKashida/highKashida/lowKashida/
  thaiDistribute/numTab); `values:` on `Alignment#value`.
- `lib/uniword/properties/table_justification.rb` — `values:` with the
  5-value ST_JcTable.
- `lib/uniword/properties/highlight.rb` — `HighlightValue::VALUES` =
  full 17-value ST_HighlightColor; `values:` on `Highlight#value`.
- `lib/uniword/properties/border.rb` — `BorderStyleValue::VALUES` = full
  193-value ST_Border (generated verbatim from wml.xsd); `values:` on
  `style`; `color` typed HexColorValue; `theme_color` typed
  ThemeColorValue with `values:`.
- `lib/uniword/properties/color_value.rb` — `ColorValueType` now
  subclasses `Ooxml::Types::HexColorValue` (inherits the cast
  constraint); `theme_color` typed ThemeColorValue with `values:`.
- `lib/uniword/properties/underline.rb` — `color` typed HexColorValue;
  `theme_color` typed ThemeColorValue with `values:`.
- `lib/uniword/properties/shading.rb` — `color`/`fill` typed
  HexColorValue; `theme_fill` typed ThemeColorValue with `values:`.
- `lib/uniword/properties/vertical_align.rb` — `values:` with the
  3-value ST_VerticalAlignRun.
- `lib/uniword/properties/cell_vertical_align.rb` — `values:` with the
  4-value ST_VerticalJc.
- `lib/uniword/properties/tab_stop.rb` — `values:` with the 9-value
  ST_TabJc.
- `lib/uniword/wordprocessingml/w14_attributes.rb` — `W14ParaId`/
  `W14TextId` `cast` enforces ST_LongHexNumber (exactly 8 hex digits,
  case-insensitive) via a shared
  `Wordprocessingml.cast_long_hex_number` helper; nil/uninitialized pass
  through.

### Deliberately NOT constrained (with reasons)

- `SharedTypes::OnOff`, `SharedTypes::BooleanValue` and the
  `BooleanElementFactory`-generated classes (Bold, Italic, ...): adding
  `values:` makes lutaml-model install its enum getter, which calls
  `.uniq` on the plain String stored by the `BooleanValSetter` custom
  setter -> NoMethodError. ST_OnOff enforcement lands in OoxmlBoolean
  instead (as the task specifies).
- `SharedTypes::DecimalNumber` (ST_DecimalNumber is signed xsd:integer),
  `SharedTypes::Angle` (ST_Angle is signed), `SharedTypes::EmuMeasure`
  (signedness ambiguous between ST_Coordinate/ST_PositiveCoordinate).
- `SharedTypes::VerticalAlignment` — generated class with no consumers;
  its source simple type is ambiguous (wml ST_VerticalJc vs DrawingML
  types), so no enum was guessed.
- `Wordprocessingml::Shading` (`lib/uniword/wordprocessingml/shading.rb`)
  — same ST_ThemeColor/ST_HexColor attributes but outside the tasked
  directories; follow-up candidate.
- `Properties::Shading#pattern` (ST_Shd) and `Underline#value`
  (ST_Underline) — not in the task's type list; follow-up candidates.

### Round-trip safety / fixture audit

No enum widenings were needed: `values:` does not affect parsing, and all
fixture values for the cast-constrained types were verified against
~60 DOCX files under spec/fixtures, test_output, tmp, verify_stats
BEFORE choosing cast-raise:

- w14:paraId/textId: all 8-hex (textId `77777777` dominant).
- Boolean attributes (w:default, w:customStyle, lsdException flags):
  only "0"/"1".
- w:color val, w:shd color/fill, w:u color, border color: all `auto` or
  6 hex digits.

### Generator wiring

- `lib/uniword/schema/model_generator.rb` now emits `values: %w[...]`
  and `pattern: /.../` when the YAML attribute carries `values:`/
  `pattern:` keys, and passes custom type class names through verbatim
  (fixed a pre-existing normalization bug where YAML Symbol types like
  `:string` lost their colon and produced invalid Ruby). Extracted
  `generate_attribute`/`attribute_type` helpers to stay within ABC
  limits.
- `config/ooxml/schemas/shared_types.yml` updated for the in-scope
  types: hex_color -> HexColorValue, twips/point/pixel_measure ->
  UnsignedDecimalNumber, text_alignment -> values list. These YAML files
  feed only the ModelGenerator (runtime Ooxml::Schema reads
  `config/ooxml/schema_loader.yml`/`schema_main.yml`), so no runtime
  impact.
- Cosmetic mismatch accepted: lib `text_alignment.rb` uses a `VALUES`
  constant while the generator emits an inline `%w[...]`.
- New spec: `spec/uniword/schema/model_generator_spec.rb`.

### Specs and results

- 22 new spec files (mirroring lib/): spec/uniword/ooxml/types/ (5),
  spec/uniword/shared_types/ (5), spec/uniword/properties/ (10),
  spec/uniword/wordprocessingml/w14_para_id_spec.rb +
  w14_text_id_spec.rb, spec/uniword/schema/model_generator_spec.rb.
  Each covers: valid values accepted (validate empty / cast OK),
  garbage rejected (InvalidValueError in `validate`, or raise at
  assignment for cast-constrained types), serialized form unchanged, and
  parse-without-raise for enum values (round-trip safety).
- Suites: `spec/uniword/wordprocessingml/ spec/uniword/properties/
  spec/uniword/ooxml/ spec/uniword/builder/ spec/uniword/docx/` plus new
  spec dirs and `spec/transformation/`: 1574 examples, 0 new failures
  (12 pending pre-existing). The single failure,
  `spec/uniword/docx/id_allocator_spec.rb:70` (expects 12-char hex,
  allocator returns 8), is PRE-EXISTING on main — verified by running it
  with all my changes stashed; it comes from commit 98f1342a ("ID
  lengths") and is unrelated.
- RuboCop: all changed lib/spec files clean (only pre-existing offenses
  remain on untouched lines of types.rb, w14_attributes.rb,
  model_generator.rb).
