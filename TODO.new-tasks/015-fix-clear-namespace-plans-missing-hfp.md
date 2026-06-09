# 015: Fix `clear_stored_namespace_plans` missing header/footer parts

## Status: DONE

## Problem

`Reconciler#clear_stored_namespace_plans` clears XML parse state on package
parts but does NOT include header/footer parts from the round-trip path:

```ruby
def clear_stored_namespace_plans
  parts = [
    package.document,
    package.settings,
    # ...
    package.footnotes,
    package.endnotes,
  ].compact

  parts.each(&:clear_xml_parse_state!)
end
```

Header/footer parts are stored in `document.header_footer_parts` as
`{content: Header/Footer}` hashes. These are NOT included in the `parts`
array, so their `element_order` arrays remain frozen from XML parsing.
This can cause serialization issues when the reconciler modifies paragraphs
inside headers/footers (via `reconcile_headers_footers`).

## Fix

Add header/footer parts to the cleanup:

```ruby
parts = [
  # ... existing parts ...
]

(package.document&.header_footer_parts || []).each do |part|
  parts << part[:content] if part[:content]
end

(package.document&.headers&.values || []).each { |h| parts << h }
(package.document&.footers&.values || []).each { |f| parts << f }

parts.compact.each(&:clear_xml_parse_state!)
```

## Files
- `lib/uniword/docx/reconciler.rb` (lines 104-119)
