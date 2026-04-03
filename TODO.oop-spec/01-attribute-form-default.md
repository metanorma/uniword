# 01-attribute-form-default.md

# Fix: Change attribute_form_default to unqualified

## Problem
OOXML namespaces in `lib/uniword/ooxml/namespaces.rb` have `attribute_form_default :qualified`.
OOXML uses `attributeFormDefault="unqualified"` — attributes should NEVER have namespace prefixes.

This causes ALL attributes to render with `w:` prefix (e.g., `w:val="1"`) instead of bare `val="1"`.
This is the root cause of duplicate attribute issues across 35+ files.

## Fix

### File: `lib/uniword/ooxml/namespaces.rb`

Change `WordProcessingML` namespace:
```ruby
# FROM:
attribute_form_default :qualified

# TO:
attribute_form_default :unqualified
```

Also check and fix `MathML`, `DrawingML`, `SpreadsheetML`, `OfficeDocument`, `Office`, `VML`, `Relationships`, and any other OOXML namespaces with `attribute_form_default :qualified`.

## Verification
```bash
bundle exec rspec spec/uniword/ooxml/complete_roundtrip_spec.rb:115
```
Before fix: duplicate `w:val`+`val` attrs
After fix: only `val` attrs
