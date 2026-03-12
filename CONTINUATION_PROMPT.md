# Autoload Migration Continuation Prompt

## Mission

Convert `require_relative` statements to `autoload` following the principle:
> **"All autoload statements need to be done in the immediate parent namespace's ruby file."**

## Context

The codebase has 385 `require_relative` statements. We've already created 13 namespace files. Now we need to:
1. Create remaining namespace files
2. Remove `require_relative` from individual class files
3. Rely on autoload instead

## Work Already Completed

1. Created 13 namespace files:
   - `lib/uniword/styles.rb`
   - `lib/uniword/template.rb`
   - `lib/uniword/visitor.rb`
   - `lib/uniword/validators.rb`
   - `lib/uniword/stylesets.rb`
   - `lib/uniword/infrastructure.rb`
   - `lib/uniword/accessibility.rb`
   - `lib/uniword/accessibility/rules.rb`
   - `lib/uniword/assembly.rb`
   - `lib/uniword/batch.rb`
   - `lib/uniword/metadata.rb`
   - `lib/uniword/quality.rb`
   - `lib/uniword/schema.rb`

2. Updated `lib/uniword.rb` to add namespace autoloads

## Your Task

Read the detailed plan: `REQUIRE_RELATIVE_TO_AUTOLOAD_PLAN.md`

### Phase 1: Create These Namespace Files

```ruby
# lib/uniword/configuration.rb
module Uniword
  module Configuration
    autoload :ConfigurationLoader, "#{__dir__}/configuration/configuration_loader"
  end
end

# lib/uniword/transformation.rb
module Uniword
  module Transformation
    autoload :Transformer, "#{__dir__}/transformation/transformer"
    autoload :RunTransformationRule, "#{__dir__}/transformation/run_transformation_rule"
    autoload :TableTransformationRule, "#{__dir__}/transformation/table_transformation_rule"
  end
end

# lib/uniword/validation.rb
module Uniword
  module Validation
    autoload :ValidationResult, "#{__dir__}/validation/validation_result"
    autoload :ValidationReport, "#{__dir__}/validation/validation_report"
    autoload :LinkChecker, "#{__dir__}/validation/link_checker"
    autoload :LinkValidator, "#{__dir__}/validation/link_validator"
    autoload :LayerValidator, "#{__dir__}/validation/layer_validator"
    autoload :LayerValidationResult, "#{__dir__}/validation/layer_validation_result"
    autoload :DocumentValidator, "#{__dir__}/validation/document_validator"
    autoload :Checkers, "#{__dir__}/validation/checkers"
    autoload :Validators, "#{__dir__}/validation/validators"
  end
end

# lib/uniword/validation/checkers.rb
module Uniword
  module Validation
    module Checkers
    end
  end
end

# lib/uniword/validation/validators.rb
module Uniword
  module Validation
    module Validators
    end
  end
end

# lib/uniword/warnings.rb
module Uniword
  module Warnings
    autoload :Warning, "#{__dir__}/warnings/warning"
    autoload :WarningCollector, "#{__dir__}/warnings/warning_collector"
    autoload :WarningReport, "#{__dir__}/warnings/warning_report"
  end
end

# lib/uniword/mhtml.rb
module Uniword
  module Mhtml
    autoload :CssNumberFormatter, "#{__dir__}/mhtml/css_number_formatter"
    autoload :WordCss, "#{__dir__}/mhtml/word_css"
  end
end

# lib/uniword/themes.rb
module Uniword
  module Themes
    autoload :ThemeLoader, "#{__dir__}/theme/theme_loader"
    autoload :ThemeApplicator, "#{__dir__}/theme/theme_applicator"
    autoload :ThemeVariant, "#{__dir__}/theme/theme_variant"
    autoload :ThemeImporter, "#{__dir__}/themes/theme_importer"
    autoload :YamlThemeLoader, "#{__dir__}/themes/yaml_theme_loader"
  end
end

# lib/uniword/sdt.rb
module Uniword
  module Sdt
    autoload :Id, "#{__dir__}/sdt/id"
    autoload :Alias, "#{__dir__}/sdt/alias"
    autoload :Tag, "#{__dir__}/sdt/tag"
  end
end
```

### Phase 2: Update lib/uniword.rb

Add autoloads for new namespaces.

### Phase 3: Remove require_relative

Remove `require_relative` statements from files that reference classes in different namespaces.

## Requires that MUST Stay

1. Root-level requires in `lib/uniword.rb` (load order dependencies)
2. Gem dependencies (`require 'nokogiri'`)
3. Inheritance chains (where parent class must be loaded first)

## Verification

```bash
# Run tests after each phase
bundle exec rspec --format progress

# Verify autoloads
bundle exec ruby -e "
require_relative 'lib/uniword'
puts Uniword::Configuration::ConfigurationLoader
puts Uniword::Validation::DocumentValidator
puts Uniword::Mhtml::WordCss
"

# Run Rubocop
bundle exec rubocop -A
```
