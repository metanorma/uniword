# Fix: URI:name format detection in value_for_xml_attribute

## Summary

Fixed the deserialization of attributes with type-level namespace declarations (like `v:ext` in VML) by improving the URI format detection in `value_for_xml_attribute`.

## Problem

When parsing XML with namespaced attributes like `<v:ext="edit">`, the deserialization failed because:

1. `resolve_rule_names_with_type` correctly returned `["urn:schemas-microsoft-com:vml:ext"]` (URI:name format)
2. But `value_for_xml_attribute` only checked for `"://"` to detect URI formats
3. OOXML uses URNs like `urn:schemas-microsoft-com:vml:ext` which don't have `://`
4. The URN format wasn't recognized, so the attribute value was never found

## Solution

Changed the URI format detection in `lib/lutaml/xml/model_transform.rb`:

```ruby
# Before (only matched HTTP/HTTPS URIs):
if rn.include?("://")

# After (matches HTTP/HTTPS URIs and URNs):
is_uri_format = (rn.include?("://") || rn.start_with?("urn:")) && rn.count(":") >= 2
if is_uri_format
```

## Files Modified

- `/Users/mulgogi/src/lutaml/lutaml-model/lib/lutaml/xml/model_transform.rb`

## Test Results

- VML `v:ext` attribute now parses correctly: `ext: "edit"` instead of `ext: nil`
- All 13 OOXML round-trip tests pass
- VML shape elements (`shapedefaults`, `shapelayout`, `idmap`) with `v:ext` attribute now deserialize correctly

## Status

FIXED - March 22, 2026
