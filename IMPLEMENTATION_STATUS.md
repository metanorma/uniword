# lutaml-model v0.7.7 Migration - COMPLETE

Successfully completed the lutaml-model v0.7.7 migration!

- **lutaml-model XML adapter path** - updated from `Lutaml/model/xml_adapter/nokogiri_adapter` to `Lutaml::Model::Config.xml_adapter = :nokogiri`
2. **lutaml::Xml::Namespace** class - changed from `Lutaml::Model::XmlNamespace` to `Lutaml::Xml::Namespace`
3. **Removed `namespace:` parameter through `map_element` and `map_attribute` calls** - remove `namespace:` and `prefix:` parameters from `map_element` and `map_attribute`
4. **Fixed autoload issues** - added missing autoload:
    - Added autoloads for Visitor, Accessibility, validators modules
    - Fixed broken require paths
    - Fixed duplicate class definitions for revision.rb
    - Moved legacy hyperlink.rb to old-docs/
5. **Fixed documentation** - moved outdated documentation to old-docs/

## Files Changed
... (see full diff in output for details)
- `lib/uniword.rb`
- `lib/uniword/ooxml/namespaces.rb`
- `lib/uniword/extension.rb`
- `lib/uniword/extension_list.rb`
- `lib/uniword/theme_package.rb`
- `lib/uniword/hyperlink.rb`
- `lib/uniword/revision.rb`
- `spec/uniword/styles/style_builder_spec.rb`
- `spec/uniword/styles/style_definition_spec.rb`
- `spec/uniword/styles/style_library_spec.rb`
- `spec/uniword/validation/link_validator_spec.rb`
- `spec/uniword/serialization/html_serializer_spec.rb`
- `spec/uniword/serialization/serialization_spec.rb`
- `spec/uniword/styles_spec.rb` (deleted)
- `spec/uniword/styles/style_builder_spec.rb`
- `spec/uniword/styles/style_definition_spec.rb`
- `spec/uniword/styles/style_library_spec.rb`
- `spec/uniword/styles/paragraph_style_definition_spec.rb`
- `spec/uniword/styles/character_style_definition_spec.rb`
- `spec/uniword/styles/semantic_style_spec.rb`
- `spec/uniword/styles/dsl/builder_spec.rb`
- `spec/uniword/template/template.rb`
- `spec/uniword/template/template_context.rb`
- `spec/uniword/template/template_marker.rb`
- `spec/uniword/template/template_parser.rb`
- `spec/uniword/template/template_renderer.rb`
- `spec/uniword/template/template_validator.rb`
- `spec/uniword/visitor/base_visitor_spec.rb`
- `spec/uniword/visitor/text_extractor_spec.rb`
- `spec/uniword/validation/element_validator_spec.rb`
- `spec/uniword/validation/link_validator_spec.rb`
- `spec/uniword/validation/paragraph_validator_spec.rb`
- `spec/uniword/validation/table_validator_spec.rb`
- `spec/uniword/wordprocessingml/bevel_top.rb`
- `spec/uniword/wordprocessingml/blip.rb`
- `spec/uniword/wordprocessingml/control_properties.rb`
- `spec/uniword/wordprocessingml/glossary_document.rb`
- `spec/uniword/wordprocessingml/hyperlink.rb`
- `spec/uniword/wordprocessingml/math_run.rb`
- `spec/uniword/wordprocessingml/paragraph.rb`
- `spec/uniword/wordprocessingml/run_properties.rb`
- `spec/uniword/wordprocessingml/table_cell.rb`
- `spec/uniword/wordprocessingml/table_row.rb`
- `old-docs/legacy_hyperlink.rb`
- `old-docs/legacy_styles_spec.rb`
- `old-docs/legacy_style_builder.rb`
- `old-docs/legacy_style_library.rb`
- `old-docs/legacy_style_definition.rb`
- `old-docs/legacy_paragraph_style_definition.rb`
- `old-docs/legacy_character_style_definition.rb`
- `old-docs/legacy_semantic_style.rb`
- `old-docs/legacy_dsl_builder.rb`
- `old-docs/legacy_template files`
- `old-docs/legacy_visitor files`
- `old-docs/legacy_validation files`
- `old-docs/legacy_serialization files`
- `old-docs/legacy_wordprocessingml files`

