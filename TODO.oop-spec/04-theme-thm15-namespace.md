# 04-theme-thm15-namespace.md

# Fix: ThemeFamily uses default namespace instead of thm15: prefix

## Problem
The `ThemeFamily` class declares the `ThemeML` namespace as the **default** namespace.
Root element renders as `<themeFamily xmlns="...">` instead of `<thm15:themeFamily xmlns:thm15="...">`.
The attributes `name`, `id`, `vid` lose their `thm15:` prefix.

## Fix

### File: `lib/uniword/drawingml/extension.rb`

Add `namespace_scope` to `ThemeFamily` class to force `thm15:` prefix:
```ruby
namespace_scope [
  { namespace: Uniword::Ooxml::Namespaces::ThemeML, declare: :always },
]
```

## Verification
```bash
bundle exec rspec spec/uniword/ooxml/complete_roundtrip_spec.rb:151
```
