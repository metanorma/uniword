# 02: Decompose run_properties.rb (677 lines) into property submodules

**Priority:** P1
**Effort:** Medium (~3 hours)
**File:** `lib/uniword/wordprocessingml/run_properties.rb`

## Problem

`run_properties.rb` is the second-largest model file at 677 lines. It likely
contains the RunProperties class with dozens of inline property declarations
for every possible run-level formatting attribute (bold, italic, underline,
font, color, size, spacing, effects, borders, etc.).

This is a model-driven class using lutaml-model, so it's fundamentally attribute
declarations + XML mappings. But 677 lines in one file makes it hard to
navigate and maintain.

## Fix

Analyze the file's structure. If it contains nested classes or logical groups
(e.g., font properties, border properties, effect properties), extract each
group into its own file under `wordprocessingml/run_properties/`.

However, if it's purely `attribute` + `xml` map pairs for a single class, the
file may be appropriately sized for its complexity — lutaml-model classes are
declarative and don't benefit from arbitrary splitting.

Only decompose if there are clear logical boundaries (e.g., separate inner
classes or mixin-able property groups). Don't split for line count alone.

Same analysis applies to:
- `settings.rb` (603 lines)
- `paragraph_properties.rb` (431 lines)
- `table_properties.rb` (354 lines)
- `styles_configuration.rb` (352 lines)

## Verification

```bash
bundle exec rspec spec/uniword/wordprocessingml/
```
