# 027: Extract mc:Ignorable assignment into shared helper

## Status: DONE

## Problem

`mc_ignorable` assignment follows an identical pattern repeated 8 times
across `Parts`, `Notes`, and `Body`:

```ruby
model.mc_ignorable = Ooxml::Types::McIgnorable.new(EXTENSION_PREFIXES)
# or
model.mc_ignorable = Ooxml::Types::McIgnorable.new(FULL_IGNORABLE)
```

Locations:
- `parts.rb:69-70` — settings
- `parts.rb:83-84` — font_table (first assignment)
- `parts.rb:114-115` — font_table (second assignment)
- `parts.rb:134-135` — styles
- `parts.rb:144-145` — numbering (uses FULL_IGNORABLE)
- `parts.rb:184` — web_settings
- `parts.rb:272-273` — document body (uses FULL_IGNORABLE)
- `notes.rb:83-84` — footnotes/endnotes (uses FULL_IGNORABLE)
- `body.rb:57` — headers/footers (uses FULL_IGNORABLE)

## Fix

Add a helper in `Reconciler::Helpers`:

```ruby
def set_mc_ignorable(model, prefixes: EXTENSION_PREFIXES)
  model.mc_ignorable = Ooxml::Types::McIgnorable.new(prefixes)
end
```

This reduces each 2-line call to 1 line and centralizes the wrapping logic.
The `||=` vs `=` decision is already handled per-call-site.

## Files
- `lib/uniword/docx/reconciler/helpers.rb` (add helper)
- `lib/uniword/docx/reconciler/parts.rb` (8 call sites)
- `lib/uniword/docx/reconciler/notes.rb` (1 call site)
- `lib/uniword/docx/reconciler/body.rb` (1 call site)
