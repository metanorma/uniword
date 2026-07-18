# frozen_string_literal: true

module Uniword
  module Validation
    # Document semantic validation rules and their registry.
    module Rules
      autoload :Base, "#{__dir__}/rules/base"
      autoload :Registry, "#{__dir__}/rules/registry"
      autoload :DocumentContext, "#{__dir__}/rules/document_context"
      autoload :StyleReferencesRule,
               "#{__dir__}/rules/style_references_rule"
      autoload :NumberingRule, "#{__dir__}/rules/numbering_rule"
      autoload :FootnotesRule, "#{__dir__}/rules/footnotes_rule"
      autoload :HeadersFootersRule,
               "#{__dir__}/rules/headers_footers_rule"
      autoload :BookmarksRule, "#{__dir__}/rules/bookmarks_rule"
      autoload :ImagesRule, "#{__dir__}/rules/images_rule"
      autoload :TablesRule, "#{__dir__}/rules/tables_rule"
      autoload :FontsRule, "#{__dir__}/rules/fonts_rule"
      autoload :ThemeRule, "#{__dir__}/rules/theme_rule"
      autoload :SettingsRule, "#{__dir__}/rules/settings_rule"
      autoload :McIgnorableNamespaceRule,
               "#{__dir__}/rules/mc_ignorable_namespace_rule"
      autoload :SettingsValuesRule,
               "#{__dir__}/rules/settings_values_rule"
      autoload :ThemeCompletenessRule,
               "#{__dir__}/rules/theme_completeness_rule"
      autoload :NumberingPreservationRule,
               "#{__dir__}/rules/numbering_preservation_rule"
      autoload :SectionPropertiesRule,
               "#{__dir__}/rules/section_properties_rule"
      autoload :CorePropertiesNamespaceRule,
               "#{__dir__}/rules/core_properties_namespace_rule"
      autoload :ContentTypesCoverageRule,
               "#{__dir__}/rules/content_types_coverage_rule"
      autoload :FontTableSignatureRule,
               "#{__dir__}/rules/font_table_signature_rule"
      autoload :RelationshipIntegrityRule,
               "#{__dir__}/rules/relationship_integrity_rule"
      autoload :RsidRule, "#{__dir__}/rules/rsid_rule"
    end
  end
end

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
