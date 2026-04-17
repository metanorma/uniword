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
