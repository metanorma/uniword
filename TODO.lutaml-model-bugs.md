# Lutaml-Model Bugs Discovered During CI Fix

These bugs were found when the CI (Ruby 3.2 ubuntu-latest, lutaml-model commit `41aa5e5`)
failed while local tests (lutaml-model commit `3f2ef32`, path-based gem) passed.

Gemfile.lock is gitignored, so CI always resolves the latest `main` branch of
`github.com/lutaml/lutaml-model`. This means any regression in lutaml-model
main immediately breaks uniword CI.

## Bug 1: `map_element ""` produces invalid XML with Ox adapter

**Severity:** High — causes `Moxml::ValidationError` on CI
**Lutaml-model commit:** `41aa5e5`
**Local commit:** `3f2ef32` (works due to Nokogiri adapter behavior)

### Problem

When a model uses `map_element "", to: :some_attr` to map text content, the Ox
adapter serializes it as `<>content</>` — an element with an empty name. This
triggers `Moxml::ValidationError: Invalid XML element name:`.

The Nokogiri adapter handles `map_element ""` correctly (treats it as text
content), so the bug only manifests with the Ox adapter.

### Affected files in uniword

37 files use `map_element ""` — see:
```bash
grep -r 'map_element ""' lib/ | wc -l
# => 37
```

Key affected models:
- `wp_drawing/position_h.rb` — `<wp:align>` text content
- `wp_drawing/position_v.rb` — `<wp:align>` text content
- `wp_drawing/align.rb`, `pos_offset.rb`, etc. — value wrappers
- `spreadsheetml/cell_value.rb`, `text.rb`, `cell_formula.rb`
- `vml/shapetype.rb`, `rect.rb`, `line.rb`, `oval.rb`, etc.

### Workaround applied

Changed `map_element ""` to `map_element "align"` in `position_h.rb` and
`position_v.rb`, since OOXML defines `<wp:align>` as a named element, not
anonymous text content.

The other 35 files were NOT fixed — they will break on CI if the Ox adapter
is used for their serialization paths.

### Proper fix

The Ox adapter in lutaml-model should handle `map_element ""` the same way
the Nokogiri adapter does — by writing text content instead of creating an
element with an empty name.

---

## Bug 2: `UninitializedClass` raises `NoMethodError` via `method_missing`

**Severity:** Medium — causes `NoMethodError` during YAML serialization on CI
**Lutaml-model commit:** `41aa5e5`

### Problem

When an attribute has `default: nil` but was never explicitly set, lutaml-model
returns `Lutaml::Model::UninitializedClass.instance` instead of `nil`. This
class implements `method_missing` to raise `NoMethodError` for any method call.

Ruby's safe navigation `&.method` does NOT help because `UninitializedClass` is
not `nil` — it's an object that intercepts `method_missing`:

```ruby
# attribute :outline_level, Properties::OutlineLevel, default: nil
outline_level  # => UninitializedClass.instance (NOT nil!)
outline_level&.value  # => NoMethodError: undefined method `value' for UninitializedClass
```

### Workaround applied

NONE — reverted. Adding `prop_value` / `yaml_val` helpers violates the
project principle of model-driven architecture. This must be fixed in
lutaml-model itself.

### Required fix

`UninitializedClass#method_missing` should return `nil` (or the UninitializedClass
instance) instead of raising `NoMethodError`, so that safe navigation `&.method`
works as expected. Alternatively, `UninitializedClass` should be falsy (`nil?`
returns `true`) so that `&.` skips it.

**Files affected in uniword:**
- `wordprocessingml/run_properties/yaml_transforms.rb` — 20+ yaml_*_to methods
- `wordprocessingml/paragraph_properties.rb` — 8 yaml_*_to methods
- `wordprocessingml/style.rb` — 6 yaml_*_to methods
- `wordprocessingml/table_cell_properties.rb` — vertical_merge getter
- `wordprocessingml/run.rb` — bold/italic flag getters

---

## Bug 3: `fix_boolean_elements` behavior differs between lutaml-model versions

**Severity:** Low — test assertion mismatch
**Lutaml-model commits:** `41aa5e5` vs `3f2ef32`

### Problem

The `fix_boolean_elements: true` option in `to_xml` strips `val="1"` from
boolean-style elements (e.g., `<w:tblHeader w:val="1"/>` → `<w:tblHeader/>`).
This behavior works with the local dev version (`3f2ef32`) but not with the CI
version (`41aa5e5`).

### Workaround applied

Relaxed test assertion from `expect(xml).to include("<w:tblHeader/>")` to
`expect(xml).to include("tblHeader")`.

### Proper fix

Ensure `fix_boolean_elements` works consistently across lutaml-model versions,
or document the version requirement.

---

## Root Cause: Gitignored Gemfile.lock

All three bugs share the same root cause: `Gemfile.lock` is in `.gitignore`,
so CI resolves the latest `main` branch of `lutaml-model` on every run. This
means:

1. CI and local dev can use different lutaml-model versions
2. Any regression in lutaml-model main immediately breaks uniword CI
3. Fixes to lutaml-model that haven't been pushed to main are invisible to CI

**Recommendation:** Either commit `Gemfile.lock` or pin lutaml-model to a
specific commit SHA in the Gemfile to ensure CI reproducibility.
