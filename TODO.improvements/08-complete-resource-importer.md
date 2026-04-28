# 08: Add color_scheme and font_scheme to Resource::Importer

**Priority:** P1
**Effort:** Small (~2 hours)
**File:** `lib/uniword/resource/importer.rb`
**Data:** `data/color_schemes/`, `data/font_schemes/`

## Problem

The `Importer` class comment (line 23) documents support for `:color_scheme`
and `:font_scheme` types, but `load_from_word` (line 81) and
`available_resources` (line 102) only handle `:theme` and `:styleset`.

```ruby
# Line 23: Comment claims support
# @param type [Symbol] Resource type (:theme, :styleset, :color_scheme, :font_scheme)

# Lines 81-100: Only handles :theme and :styleset
def load_from_word(type, name)
  case type
  when :theme    then ...
  when :styleset then ...
  # :color_scheme and :font_scheme are MISSING
  end
end

# Lines 102-108: Only lists :theme and :styleset
def available_resources(type)
  case type
  when :theme    then ...
  when :styleset then ...
  # :color_scheme and :font_scheme are MISSING
  end
end
```

Data files already exist:
- `data/color_schemes/` — YAML color scheme files
- `data/font_schemes/` — YAML font scheme files

And the `ResourceResolver` can find them. The gap is only in the Importer.

## Fix

1. Add `:color_scheme` and `:font_scheme` cases to `load_from_word`:

```ruby
when :color_scheme
  ColorSchemeLoader.load(name)
when :font_scheme
  FontSchemeLoader.load(name)
```

2. Add corresponding cases to `available_resources`:

```ruby
when :color_scheme
  ResourceResolver.available(:color_scheme)
when :font_scheme
  ResourceResolver.available(:font_scheme)
```

3. Update `import_all` (line 64) to include the new types in its iteration.

4. Check if loaders exist (`ColorSchemeLoader`, `FontSchemeLoader`) or need
   creation. The `ResourceResolver` and `Cache` already handle path resolution.

## Verification

```bash
# Test that color schemes and font schemes can be imported
bundle exec rspec spec/uniword/resource/
```
