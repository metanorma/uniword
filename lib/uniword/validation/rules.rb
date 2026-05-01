# frozen_string_literal: true

require_relative "rules/base"
require_relative "rules/registry"
require_relative "rules/document_context"
require_relative "rules/style_references_rule"
require_relative "rules/numbering_rule"
require_relative "rules/footnotes_rule"
require_relative "rules/headers_footers_rule"
require_relative "rules/bookmarks_rule"
require_relative "rules/images_rule"
require_relative "rules/tables_rule"
require_relative "rules/fonts_rule"
require_relative "rules/theme_rule"
require_relative "rules/settings_rule"
require_relative "rules/mc_ignorable_namespace_rule"
require_relative "rules/settings_values_rule"
require_relative "rules/theme_completeness_rule"
require_relative "rules/numbering_preservation_rule"
require_relative "rules/section_properties_rule"
require_relative "rules/core_properties_namespace_rule"
require_relative "rules/content_types_coverage_rule"
require_relative "rules/font_table_signature_rule"
require_relative "rules/relationship_integrity_rule"
require_relative "rules/rsid_rule"

# Register all built-in validation rules
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::StyleReferencesRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::NumberingRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::FootnotesRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::HeadersFootersRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::BookmarksRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::ImagesRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::TablesRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::FontsRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::ThemeRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::SettingsRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::McIgnorableNamespaceRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::SettingsValuesRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::ThemeCompletenessRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::NumberingPreservationRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::SectionPropertiesRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::CorePropertiesNamespaceRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::ContentTypesCoverageRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::FontTableSignatureRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::RelationshipIntegrityRule)
Uniword::Validation::Rules::Registry.register(Uniword::Validation::Rules::RsidRule)
