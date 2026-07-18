# 17 — Eliminate `public_send` from lib/

**Status: COMPLETED via TODO.validate/12** — the 8 enumerated sites had
already been fixed before this wave (verified by grep); the remaining
sites (`variable_resolver.rb:116`, `element_serializer.rb:309,325`) and
the `__send__` dispatch in `model_attribute_access.rb` were replaced
with case/on-class dispatch and schema-guarded method-table lookups.
`grep -rn "public_send" lib/uniword/` returns nothing.

**Priority:** High (forbidden pattern)
**Files:**
- `lib/uniword/wordprocessingml/styles/style_definition.rb`
- `lib/uniword/template/variable_resolver.rb` (2 sites)
- `lib/uniword/ooxml/schema/element_serializer.rb` (2 sites)
- `lib/uniword/cli/main.rb`
- `lib/uniword/theme/theme_xml_parser.rb`
- `lib/uniword/drawingml/color_scheme.rb` (2 sites)

## Problem

Project rule: never use `send`/`public_send` to call methods
dynamically. Each callsite uses `public_send` to dispatch on a
string/symbol name, which:

- bypasses compile-time method-existence checks
- couples the code to method-name strings
- hides the dispatch from grep-based audit

## Per-site fixes

### `style_definition.rb:28`
```ruby
base_def = library.public_send(style_type, @base_style)
```
`style_type` is one of a small set (paragraph/character/table/etc).
Replace with a case/when or a hash of lambdas indexed by style_type.

### `variable_resolver.rb:112`
```ruby
object.public_send(property.to_sym)
```
Variable resolver dispatches on property names from template syntax.
Use a Hash of allowed property names → accessor Procs, or define
explicit reader methods per property.

### `variable_resolver.rb:178`
```ruby
left_num.public_send(operator, right_num)
```
Operator dispatch on `:+`, `:-`, etc. Use a case/when or a frozen
Hash of operator symbols → lambdas.

### `element_serializer.rb:306, 322`
```ruby
element.public_send(property_name)
```
Schema-driven serializer that reads attributes by name. This is
legitimate dynamic dispatch over a schema, but can be replaced with
`element.attribute_value(property_name)` if the underlying model
exposes such a method, or with `Lutaml::Model`'s typed access API.

### `cli/main.rb:514`
```ruby
core_properties&.public_send(setter, options[opt])
```
CLI option → core_properties setter. Use a Hash of option names →
explicit setter Procs.

### `theme_xml_parser.rb:82`
```ruby
scheme.public_send(:"#{attr_name}=", color_obj)
```
XML attribute → scheme color setter. Replace with a Hash of
attr_name → Proc, or refactor ColorScheme to expose a typed
`set_color(name, value)` method.

### `color_scheme.rb:316, 348`
Same as theme_xml_parser — internal access by name. Add typed
accessors.

## Verification

- `grep -rn "public_send" lib/uniword/` returns nothing (or only
  unavoidable cases documented with reasons)
- All affected specs pass
