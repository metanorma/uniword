# Plan: Convert `require_relative` to Autoload

## Context

The codebase currently has 385 `require_relative` statements scattered across files. The goal is to convert most of these to `autoload` statements following the principle:

> **"All autoload statements need to be done in the immediate parent namespace's ruby file."**

This builds on the previous migration that created namespace files for autoloads.

## Current State Analysis

### Categories of `require_relative`

#### 1. Root-Level Requires in `lib/uniword.rb` (10 statements)

These are **REQUIRED to stay** as `require_relative` due to load order dependencies:

```ruby
require_relative 'uniword/version'           # Version constant needed immediately
require_relative 'uniword/ooxml/namespaces'  # Namespaces needed by generated classes
require_relative 'uniword/ooxml'             # OOXML module with autoloads
require_relative 'uniword/properties'        # Properties module with autoloads
require_relative 'uniword/wordprocessingml'  # Core namespace - cross-dependencies
require_relative 'uniword/wp_drawing'        # Drawing namespace - cross-dependencies
require_relative 'uniword/drawingml'         # DrawingML namespace - cross-dependencies
require_relative 'uniword/vml'               # VML namespace - cross-dependencies
require_relative 'uniword/math'              # Math namespace - cross-dependencies
require_relative 'uniword/shared_types'      # Shared types - cross-dependencies
```

**Action**: KEEP AS-IS. These are foundational modules that must be loaded early.

#### 2. Cross-Namespace Requires (50+ statements)

These should be **CONVERTED to autoload** in the immediate parent namespace file:

| File | Current Pattern | Target Autoload Location |
|------|-----------------|--------------------------|
| `assembly/document_assembler.rb` | `require_relative '../document_factory'` | `Uniword` namespace autoload |
| `batch/document_processor.rb` | `require_relative '../document_factory'` | `Uniword` namespace autoload |
| `batch/document_processor.rb` | `require_relative '../configuration/configuration_loader'` | `Uniword::Configuration` namespace autoload |
| `cli.rb` | `require_relative 'document_factory'` | `Uniword` namespace autoload |
| `cli.rb` | `require_relative 'document_writer'` | `Uniword` namespace autoload |
| `cli.rb` | `require_relative 'format_detector'` | `Uniword` namespace autoload |
| `cli.rb` | `require_relative 'errors'` | `Uniword` namespace autoload |
| `document_factory.rb` | `require_relative 'errors'` | `Uniword` namespace autoload |
| `document_factory.rb` | `require_relative 'ooxml/docx_package'` | `Uniword::Ooxml` namespace autoload |
| `document_factory.rb` | `require_relative 'ooxml/dotx_package'` | `Uniword::Ooxml` namespace autoload |
| `document_factory.rb` | `require_relative 'ooxml/mhtml_package'` | `Uniword::Ooxml` namespace autoload |
| `document_factory.rb` | `require_relative 'ooxml/thmx_package'` | `Uniword::Ooxml` namespace autoload |
| `document_factory.rb` | `require_relative 'format_detector'` | `Uniword` namespace autoload |
| `format_converter.rb` | `require_relative 'transformation/transformer'` | `Uniword::Transformation` namespace autoload |
| `format_converter.rb` | `require_relative 'document_factory'` | `Uniword` namespace autoload |
| `format_converter.rb` | `require_relative 'document_writer'` | `Uniword` namespace autoload |
| `quality/document_checker.rb` | `require_relative '../configuration/configuration_loader'` | `Uniword::Configuration` namespace autoload |
| `metadata/metadata_*.rb` | `require_relative '../configuration/configuration_loader'` | `Uniword::Configuration` namespace autoload |
| `validation/*.rb` | `require_relative '../configuration/configuration_loader'` | `Uniword::Configuration` namespace autoload |

#### 3. Intra-Namespace Requires (100+ statements)

These should be **CONVERTED to autoload** in the namespace file:

**Assembly Namespace:**
```ruby
# lib/uniword/assembly/document_assembler.rb
require_relative 'assembly_manifest'      # → autoload in assembly.rb
require_relative 'component_registry'     # → autoload in assembly.rb
require_relative 'variable_substitutor'   # → autoload in assembly.rb
require_relative 'toc_generator'          # → autoload in assembly.rb
require_relative 'cross_reference_resolver' # → autoload in assembly.rb
```

**Batch Namespace:**
```ruby
# lib/uniword/batch/document_processor.rb
require_relative 'processing_stage'  # → autoload in batch.rb
require_relative 'batch_result'      # → autoload in batch.rb
```

**Metadata Namespace:**
```ruby
# lib/uniword/metadata/metadata_manager.rb
require_relative 'metadata'           # → autoload in metadata.rb
require_relative 'metadata_extractor' # → autoload in metadata.rb
require_relative 'metadata_updater'   # → autoload in metadata.rb
require_relative 'metadata_validator' # → autoload in metadata.rb
require_relative 'metadata_index'     # → autoload in metadata.rb
```

**Quality Namespace:**
```ruby
# lib/uniword/quality/document_checker.rb
require_relative 'quality_rule'   # → autoload in quality.rb
require_relative 'quality_report' # → autoload in quality.rb
```

**Validation Namespace:**
```ruby
# lib/uniword/validation/document_validator.rb
require_relative 'layer_validator'          # → autoload in validation.rb
require_relative 'layer_validation_result'  # → autoload in validation.rb
require_relative 'validators/file_structure_validator'  # → autoload in validation/validators.rb
# ... etc
```

**Template Namespace:**
```ruby
# lib/uniword/template/template.rb
require_relative 'template_parser'    # → autoload in template.rb
require_relative 'template_renderer'  # → autoload in template.rb
require_relative 'template_marker'    # → autoload in template.rb
require_relative 'template_validator' # → autoload in template.rb
```

#### 4. Dynamic Requires (10+ statements)

These are **COMPLEX** and require special handling:

```ruby
# lib/uniword/batch/document_processor.rb
require_relative "stages/#{class_name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase}"

# lib/uniword/quality/document_checker.rb
require_relative "rules/#{class_name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase}"
```

**Action**: These can potentially be converted to a registry pattern or kept as-is with explicit autoloads.

#### 5. Conditional Requires (5+ statements)

These require careful handling:

```ruby
# lib/uniword/comment.rb
require_relative 'paragraph' unless defined?(Uniword::Paragraph)

# lib/uniword/math_equation.rb
require_relative 'math/plurimath_adapter' if defined?(Plurimath)
```

**Action**: Convert to autoload - autoload handles this automatically.

#### 6. Properties Requires (30+ statements)

These are in property-heavy classes:

```ruby
# lib/uniword/wordprocessingml/run_properties.rb
require_relative '../properties/run_fonts'
require_relative '../properties/font_size'
# ... many more
```

**Action**: Convert to autoloads in `Uniword::Properties` namespace file.

## Missing Namespace Files

The following namespace files need to be created:

| Namespace | File to Create |
|-----------|----------------|
| `Uniword::Configuration` | `lib/uniword/configuration.rb` |
| `Uniword::Transformation` | `lib/uniword/transformation.rb` |
| `Uniword::Validation` | `lib/uniword/validation.rb` |
| `Uniword::Validation::Checkers` | `lib/uniword/validation/checkers.rb` |
| `Uniword::Validation::Validators` | `lib/uniword/validation/validators.rb` |
| `Uniword::Warnings` | `lib/uniword/warnings.rb` |
| `Uniword::Mhtml` | `lib/uniword/mhtml.rb` |
| `Uniword::Themes` | `lib/uniword/themes.rb` |
| `Uniword::Stylesets` (enhance) | `lib/uniword/stylesets.rb` |
| `Uniword::Sdt` | `lib/uniword/sdt.rb` |
| `Uniword::Glossary` (enhance) | `lib/uniword/glossary.rb` |
| `Uniword::Properties` (enhance) | `lib/uniword/properties.rb` |

## Implementation Plan

### Phase 1: Create Missing Namespace Files (Priority: High)

**Step 1.1**: Create `lib/uniword/configuration.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Configuration
    autoload :ConfigurationLoader, "#{__dir__}/configuration/configuration_loader"
  end
end
```

**Step 1.2**: Create `lib/uniword/transformation.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Transformation
    autoload :Transformer, "#{__dir__}/transformation/transformer"
    autoload :RunTransformationRule, "#{__dir__}/transformation/run_transformation_rule"
    autoload :TableTransformationRule, "#{__dir__}/transformation/table_transformation_rule"
  end
end
```

**Step 1.3**: Create `lib/uniword/validation.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Validation
    autoload :LayerValidator, "#{__dir__}/validation/layer_validator"
    autoload :LayerValidationResult, "#{__dir__}/validation/layer_validation_result"
    autoload :ValidationResult, "#{__dir__}/validation/validation_result"
    autoload :ValidationReport, "#{__dir__}/validation/validation_report"
    autoload :LinkChecker, "#{__dir__}/validation/link_checker"
    autoload :LinkValidator, "#{__dir__}/validation/link_validator"
    autoload :DocumentValidator, "#{__dir__}/validation/document_validator"
    autoload :Checkers, "#{__dir__}/validation/checkers"
    autoload :Validators, "#{__dir__}/validation/validators"
  end
end
```

**Step 1.4**: Create `lib/uniword/validation/checkers.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Validation
    module Checkers
      autoload :InternalLinkChecker, "#{__dir__}/checkers/internal_link_checker"
      autoload :ExternalLinkChecker, "#{__dir__}/checkers/external_link_checker"
      autoload :FileReferenceChecker, "#{__dir__}/checkers/file_reference_checker"
      autoload :FootnoteReferenceChecker, "#{__dir__}/checkers/footnote_reference_checker"
    end
  end
end
```

**Step 1.5**: Create `lib/uniword/validation/validators.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Validation
    module Validators
      autoload :FileStructureValidator, "#{__dir__}/validators/file_structure_validator"
      autoload :ZipIntegrityValidator, "#{__dir__}/validators/zip_integrity_validator"
      autoload :OoxmlPartValidator, "#{__dir__}/validators/ooxml_part_validator"
      autoload :XmlSchemaValidator, "#{__dir__}/validators/xml_schema_validator"
      autoload :RelationshipValidator, "#{__dir__}/validators/relationship_validator"
      autoload :ContentTypeValidator, "#{__dir__}/validators/content_type_validator"
      autoload :DocumentSemanticsValidator, "#{__dir__}/validators/document_semantics_validator"
    end
  end
end
```

**Step 1.6**: Create `lib/uniword/warnings.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Warnings
    autoload :Warning, "#{__dir__}/warnings/warning"
    autoload :WarningCollector, "#{__dir__}/warnings/warning_collector"
    autoload :WarningReport, "#{__dir__}/warnings/warning_report"
  end
end
```

**Step 1.7**: Create `lib/uniword/mhtml.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Mhtml
    autoload :MimeParser, "#{__dir__}/mhtml/mime_parser"
    autoload :MimePackager, "#{__dir__}/mhtml/mime_packager"
    autoload :WordCss, "#{__dir__}/mhtml/word_css"
    autoload :CssNumberFormatter, "#{__dir__}/mhtml/css_number_formatter"
  end
end
```

**Step 1.8**: Create `lib/uniword/themes.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Themes
    autoload :YamlThemeLoader, "#{__dir__}/themes/yaml_theme_loader"
    autoload :ThemeImporter, "#{__dir__}/themes/theme_importer"
  end
end
```

**Step 1.9**: Create `lib/uniword/sdt.rb`
```ruby
# frozen_string_literal: true

module Uniword
  module Sdt
    autoload :Id, "#{__dir__}/sdt/id"
    autoload :Alias, "#{__dir__}/sdt/alias"
    autoload :Tag, "#{__dir__}/sdt/tag"
    autoload :Text, "#{__dir__}/sdt/text"
    autoload :ShowingPlaceholderHeader, "#{__dir__}/sdt/showing_placeholder_header"
    autoload :Appearance, "#{__dir__}/sdt/appearance"
    autoload :Placeholder, "#{__dir__}/sdt/placeholder"
    autoload :DataBinding, "#{__dir__}/sdt/data_binding"
    autoload :Bibliography, "#{__dir__}/sdt/bibliography"
    autoload :Temporary, "#{__dir__}/sdt/temporary"
    autoload :DocPartObj, "#{__dir__}/sdt/doc_part_obj"
    autoload :Date, "#{__dir__}/sdt/date"
    autoload :RunProperties, "#{__dir__}/sdt/run_properties"
  end
end
```

### Phase 2: Update lib/uniword.rb with New Namespace Autoloads

Add namespace autoloads for new namespaces:

```ruby
# In lib/uniword.rb, add to namespace autoloads section:
autoload :Configuration, "#{__dir__}/configuration"
autoload :Transformation, "#{__dir__}/transformation"
autoload :Validation, "#{__dir__}/validation"
autoload :Warnings, "#{__dir__}/warnings"
autoload :Mhtml, "#{__dir__}/mhtml"
autoload :Themes, "#{__dir__}/themes"
autoload :Sdt, "#{__dir__}/sdt"
```

### Phase 3: Remove Cross-Namespace Requires from Individual Files

For each file with cross-namespace requires, remove the `require_relative` statements:

**Example: `lib/uniword/cli.rb`**
```ruby
# BEFORE:
require_relative 'document_factory'
require_relative 'document_writer'
require_relative 'format_detector'
require_relative 'errors'

# AFTER: (remove all - autoloads in uniword.rb handle these)
# (no require_relative statements needed)
```

**Example: `lib/uniword/document_factory.rb`**
```ruby
# BEFORE:
require_relative 'errors'
# ... inside methods:
require_relative 'ooxml/docx_package'
require_relative 'ooxml/dotx_package'
require_relative 'ooxml/mhtml_package'
require_relative 'ooxml/thmx_package'
require_relative 'format_detector'

# AFTER: (remove all - autoloads handle these)
# (no require_relative statements needed)
```

### Phase 4: Remove Intra-Namespace Requires

For each namespace, remove internal requires:

**Example: `lib/uniword/assembly/document_assembler.rb`**
```ruby
# BEFORE:
require_relative 'assembly_manifest'
require_relative 'component_registry'
require_relative 'variable_substitutor'
require_relative 'toc_generator'
require_relative 'cross_reference_resolver'

# AFTER: (remove all - autoloads in assembly.rb handle these)
# (no require_relative statements needed)
```

### Phase 5: Handle Dynamic Requires

Convert dynamic requires to explicit autoloads or a registry pattern:

**Option A: Explicit Autoloads**

In `lib/uniword/batch.rb`, add all stage autoloads:
```ruby
module Uniword
  module Batch
    # ... existing autoloads ...

    # Stages (previously dynamically loaded)
    autoload :CompressImagesStage, "#{__dir__}/batch/stages/compress_images_stage"
    autoload :ConvertFormatStage, "#{__dir__}/batch/stages/convert_format_stage"
    autoload :NormalizeStylesStage, "#{__dir__}/batch/stages/normalize_styles_stage"
    autoload :QualityCheckStage, "#{__dir__}/batch/stages/quality_check_stage"
    autoload :UpdateMetadataStage, "#{__dir__}/batch/stages/update_metadata_stage"
    autoload :ValidateLinksStage, "#{__dir__}/batch/stages/validate_links_stage"
  end
end
```

Then in `lib/uniword/batch/document_processor.rb`, replace dynamic require with:
```ruby
# BEFORE:
stage_class = "#{stage_name.camelize}Stage"
require_relative "stages/#{stage_name}"

# AFTER:
stage_class = Uniword::Batch.const_get("#{stage_name.camelize}Stage")
```

### Phase 6: Update Property Requires

Enhance `lib/uniword/properties.rb` to include all property autoloads:

```ruby
# lib/uniword/properties.rb
module Uniword
  module Properties
    # Alignment
    autoload :Alignment, "#{__dir__}/properties/alignment"

    # Borders
    autoload :Borders, "#{__dir__}/properties/borders"

    # Colors
    autoload :ColorValue, "#{__dir__}/properties/color_value"

    # Fonts
    autoload :RunFonts, "#{__dir__}/properties/run_fonts"
    autoload :FontSize, "#{__dir__}/properties/font_size"

    # Spacing
    autoload :Spacing, "#{__dir__}/properties/spacing"
    autoload :Indentation, "#{__dir__}/properties/indentation"

    # ... etc for all properties
  end
end
```

### Phase 7: Handle Conditional Requires

Convert conditional requires to autoloads (autoload handles this naturally):

```ruby
# BEFORE (lib/uniword/comment.rb):
require_relative 'paragraph' unless defined?(Uniword::Paragraph)

# AFTER:
# Remove entirely - autoload in uniword.rb handles this
```

## Files to Modify

### Files to CREATE (9 new namespace files):
1. `lib/uniword/configuration.rb`
2. `lib/uniword/transformation.rb`
3. `lib/uniword/validation.rb`
4. `lib/uniword/validation/checkers.rb`
5. `lib/uniword/validation/validators.rb`
6. `lib/uniword/warnings.rb`
7. `lib/uniword/mhtml.rb`
8. `lib/uniword/themes.rb`
9. `lib/uniword/sdt.rb`

### Files to MODIFY (remove require_relative):

| File | Requires to Remove |
|------|-------------------|
| `lib/uniword.rb` | None (keep root requires) |
| `lib/uniword/cli.rb` | All 4+ require_relative |
| `lib/uniword/document_factory.rb` | All 6 require_relative |
| `lib/uniword/document_writer.rb` | All 3 require_relative |
| `lib/uniword/format_converter.rb` | All 3 require_relative |
| `lib/uniword/assembly/document_assembler.rb` | All 5 require_relative |
| `lib/uniword/assembly/component_registry.rb` | 1 require_relative |
| `lib/uniword/batch/document_processor.rb` | All 5+ require_relative |
| `lib/uniword/batch/stages/*.rb` | All require_relative |
| `lib/uniword/quality/document_checker.rb` | All require_relative |
| `lib/uniword/quality/rules/*.rb` | All require_relative |
| `lib/uniword/metadata/*.rb` | All require_relative |
| `lib/uniword/validation/*.rb` | All require_relative |
| `lib/uniword/validation/checkers/*.rb` | All require_relative |
| `lib/uniword/validation/validators/*.rb` | All require_relative |
| `lib/uniword/warnings/*.rb` | All require_relative |
| `lib/uniword/template/*.rb` | All require_relative |
| `lib/uniword/theme.rb` | All require_relative |
| `lib/uniword/styleset.rb` | All require_relative |
| `lib/uniword/stylesets/*.rb` | All require_relative |
| `lib/uniword/themes/*.rb` | All require_relative |
| `lib/uniword/wordprocessingml/*.rb` | Property requires |
| `lib/uniword/ooxml/*.rb` | Infrastructure requires |
| `lib/uniword/comment.rb` | Conditional requires |
| `lib/uniword/math_equation.rb` | Conditional requires |

## Requires that MUST Stay

These `require_relative` statements should NOT be converted to autoload:

1. **Root-level requires in `lib/uniword.rb`** - Load order dependencies
2. **Inheritance chain requires** - When class A inherits from class B, B must be loaded first
3. **Module mixin requires** - When module A is included in class B at definition time
4. **Side-effect requires** - Files that register themselves or modify global state at load time

## Verification Steps

1. **Run test suite after each phase**: `bundle exec rspec`
2. **Verify autoload resolution in console**:
   ```ruby
   Uniword::Configuration::ConfigurationLoader
   Uniword::Validation::DocumentValidator
   Uniword::Batch::DocumentProcessor
   ```
3. **Run Rubocop**: `bundle exec rubocop -A`

## Success Criteria

1. All namespace files exist with proper autoloads
2. Individual files no longer have `require_relative` for classes in the same/parent namespace
3. All tests pass
4. Rubocop passes
5. Application loads correctly and classes resolve via autoload

## Estimated Effort

| Phase | Effort | Priority |
|-------|--------|----------|
| Phase 1: Create namespace files | 1 hour | High |
| Phase 2: Update uniword.rb | 15 min | High |
| Phase 3: Remove cross-namespace requires | 2 hours | High |
| Phase 4: Remove intra-namespace requires | 2 hours | Medium |
| Phase 5: Handle dynamic requires | 1 hour | Medium |
| Phase 6: Update property requires | 1 hour | Medium |
| Phase 7: Handle conditional requires | 30 min | Low |
| **Total** | **~8 hours** | |
