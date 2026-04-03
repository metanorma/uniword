# 03-theme-blip-namespace.md

# Fix: Missing r: namespace on Blip embed attribute

## Problem
The `Blip` class maps `embed` attribute without declaring the `r:` (Relationships) namespace.
The `xmlns:r` declaration is missing from `<blip>` in theme1.xml output.

## Fix

### File: `lib/uniword/drawingml/blip.rb`

Add `namespace_scope` to `Blip` class to ensure `r:` namespace is declared:
```ruby
namespace_scope [
  { namespace: Uniword::Ooxml::Namespaces::Relationships, declare: :auto },
]
```

## Verification
```bash
bundle exec rspec spec/uniword/ooxml/complete_roundtrip_spec.rb:151
```
