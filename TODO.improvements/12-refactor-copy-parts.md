# 12: Refactor repetitive if-chain in copy_package_parts_to_document

**Priority:** P2
**Effort:** Small (~30 min)
**File:** `lib/uniword/document_factory.rb:171-189`

## Problem

18 consecutive `if X then set X` lines that are structurally identical:

```ruby
def copy_package_parts_to_document(package, document)
  return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

  document.styles_configuration = package.styles if package.styles
  document.numbering_configuration = package.numbering if package.numbering
  document.settings = package.settings if package.settings
  document.font_table = package.font_table if package.font_table
  document.web_settings = package.web_settings if package.web_settings
  document.theme = package.theme if package.theme
  document.core_properties = package.core_properties if package.core_properties
  document.app_properties = package.app_properties if package.app_properties
  document.document_rels = package.document_rels if package.document_rels
  document.theme_rels = package.theme_rels if package.theme_rels
  document.package_rels = package.package_rels if package.package_rels
  document.content_types = package.content_types if package.content_types
  document.custom_properties = package.custom_properties if package.custom_properties
  document.custom_xml_items = package.custom_xml_items if package.custom_xml_items
  document.footnotes = package.footnotes if package.footnotes
  document.endnotes = package.endnotes if package.endnotes
end
```

## Fix

Use a mapping hash:

```ruby
PACKAGE_PART_MAPPINGS = {
  styles: :styles_configuration,
  numbering: :numbering_configuration,
  settings: :settings,
  font_table: :font_table,
  web_settings: :web_settings,
  theme: :theme,
  core_properties: :core_properties,
  app_properties: :app_properties,
  document_rels: :document_rels,
  theme_rels: :theme_rels,
  package_rels: :package_rels,
  content_types: :content_types,
  custom_properties: :custom_properties,
  custom_xml_items: :custom_xml_items,
  footnotes: :footnotes,
  endnotes: :endnotes,
}.freeze

def copy_package_parts_to_document(package, document)
  return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

  PACKAGE_PART_MAPPINGS.each do |pkg_attr, doc_attr|
    value = package.send(pkg_attr)
    document.send(:"#{doc_attr}=", value) if value
  end
end
```

Note: Two names differ (`styles` → `styles_configuration`, `numbering` →
`numbering_configuration`), so a simple same-name loop won't work. The mapping
hash handles this cleanly.

## Verification

```bash
bundle exec rspec spec/integration/round_trip_spec.rb
```
