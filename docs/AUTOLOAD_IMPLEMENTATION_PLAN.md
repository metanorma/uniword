# Uniword Gem: Autoload Implementation Plan

## Executive Summary

This document provides a systematic plan to fully implement Ruby's `autoload` feature across the Uniword gem, reducing eager loading and removing most `require_relative` calls while maintaining compatibility and performance.

**Current Status**: ✅ Partially implemented (60% complete)
**Target**: 95% autoload coverage (keep require_relative only for critical dependencies)
**Estimated Time**: 6.5 hours across 6 phases

---

## Current State Analysis

### ✅ Already Implemented with Autoload

The following files already use autoload effectively:

1. **lib/uniword.rb** (Main module) - Lines 82-158
   - Infrastructure classes (DocumentFactory, DocumentWriter, FormatDetector)
   - Error classes (8 error types)
   - Style/Theme/StyleSet classes
   - Format handlers (Formats module)
   - Infrastructure (Infrastructure module)
   - OOXML support (Ooxml module)
   - Schema infrastructure (Schema module)
   - CLI class

2. **lib/uniword/drawingml.rb** - 92 classes with autoload
   - Graphics primitives, Shapes, Style references
   - Transforms, Lines, Text, Fills, Colors
   - Gradient fills, Effects, Color transforms
   - Shapes & geometry, Text properties, Line properties, 3D properties

3. **lib/uniword/wp_drawing.rb** - 26 classes with autoload
   - Complete WordprocessingDrawing namespace

4. **lib/uniword/vml.rb** - 18 classes with autoload
   - Vector Markup Language (legacy) namespace

5. **lib/uniword/math.rb** - 66 classes with autoload
   - Office Math Markup Language namespace

6. **lib/uniword/glossary.rb** - 19 classes with autoload
   - Glossary/Building blocks namespace

7. **lib/uniword/wordprocessingml.rb** - Dynamic autoload pattern
   - Uses `Dir.glob` to auto-register all classes in wordprocessingml/

### ❌ Using require_relative (Needs Review)

**Critical dependencies (KEEP require_relative):**
```ruby
# lib/uniword.rb lines 3-11
require 'lutaml/model'
require 'nokogiri'
require 'zip'
require 'lutaml/model/xml_adapter/nokogiri_adapter'

# lib/uniword.rb lines 13-27
require_relative 'uniword/version'           # ✅ KEEP - Always needed
require_relative 'uniword/ooxml/namespaces'  # ✅ KEEP - Constants needed by all
require_relative 'uniword/wordprocessingml'  # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/drawingml'         # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/wp_drawing'        # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/vml'               # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/math'              # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/shared_types'      # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/content_types'     # ⚠️  REVIEW - Namespace loader
require_relative 'uniword/document_properties' # ⚠️ REVIEW - Namespace loader
require_relative 'uniword/glossary'          # ⚠️  REVIEW - Namespace loader

# lib/uniword.rb lines 161-162
require_relative 'uniword/formats/docx_handler'   # ⚠️  REVIEW - Self-registration
require_relative 'uniword/formats/mhtml_handler'  # ⚠️  REVIEW - Self-registration
```

### 📋 Missing Namespace Loaders

These namespaces need loader files created:
1. `lib/uniword/shared_types.rb` - ❌ Does not exist
2. `lib/uniword/content_types.rb` - ❌ Does not exist (but has subfolder)
3. `lib/uniword/document_properties.rb` - ❌ Does not exist (but has subfolder)

---

## Architecture Principles

### 1. Autoload Strategy

**Use autoload for:**
- ✅ Independent classes without circular dependencies
- ✅ Namespace modules that organize related classes
- ✅ Classes that may not be used in all workflows
- ✅ Large class hierarchies (80+ classes per namespace)

**Keep require_relative for:**
- ✅ Critical base classes (version.rb, errors.rb)
- ✅ Constants needed by all code (namespaces.rb)
- ✅ Classes with circular dependencies (Document ↔ Body ↔ Paragraph)
- ✅ Self-registering components (format handlers)

### 2. Namespace Organization Pattern

**Standard Pattern** (Used by drawingml.rb, wp_drawing.rb, etc.):
```ruby
# lib/uniword/{namespace}.rb
module Uniword
  module {Namespace}
    autoload :ClassName, File.expand_path('{namespace}/class_name', __dir__)
    # ... more autoloads ...
  end
end
```

**Dynamic Pattern** (Used by wordprocessingml.rb):
```ruby
# lib/uniword/{namespace}.rb
module Uniword
  module {Namespace}
    Dir[File.join(__dir__, '{namespace}', '*.rb')].sort.each do |file|
      class_name = File.basename(file, '.rb')
                       .split('_')
                       .map(&:capitalize)
                       .join
      autoload class_name.to_sym, file
    end
  end
end
```

**Recommendation**: Use Standard Pattern for maintainability and IDE support.

### 3. Main Module Pattern

The main `lib/uniword.rb` should:
1. Require external dependencies (gems)
2. Require critical internal files (version, namespaces)
3. Autoload all namespace loaders
4. Autoload independent classes
5. Define module-level convenience methods

---

## Implementation Plan

### Phase 1: Create Missing Namespace Loaders (1 hour)

**Goal**: Create loader files for namespaces that are currently require_relative'd

#### Task 1.1: Create lib/uniword/shared_types.rb (15 min)

```ruby
# frozen_string_literal: true

# Shared Types Namespace
# Common types used across multiple OOXML namespaces

module Uniword
  module SharedTypes
    autoload :OnOff, File.expand_path('shared_types/on_off', __dir__)
    autoload :HexColor, File.expand_path('shared_types/hex_color', __dir__)
    autoload :TwipsMeasure, File.expand_path('shared_types/twips_measure', __dir__)
    autoload :HpsMeasure, File.expand_path('shared_types/hps_measure', __dir__)
    autoload :PointMeasure, File.expand_path('shared_types/point_measure', __dir__)
    autoload :Percentage, File.expand_path('shared_types/percentage', __dir__)
    # Add all other shared types...
  end
end
```

**Files to scan**: `lib/uniword/shared_types/*.rb`

#### Task 1.2: Create lib/uniword/content_types.rb (15 min)

```ruby
# frozen_string_literal: true

# Content Types Namespace
# Handles [Content_Types].xml in DOCX packages

module Uniword
  module ContentTypes
    autoload :Types, File.expand_path('content_types/types', __dir__)
    autoload :Default, File.expand_path('content_types/default', __dir__)
    autoload :Override, File.expand_path('content_types/override', __dir__)
  end
end
```

**Files to scan**: `lib/uniword/content_types/*.rb`

#### Task 1.3: Create lib/uniword/document_properties.rb (15 min)

```ruby
# frozen_string_literal: true

# Document Properties Namespace
# Handles core.xml and app.xml document properties

module Uniword
  module DocumentProperties
    autoload :Manager, File.expand_path('document_properties/manager', __dir__)
    autoload :BoolValue, File.expand_path('document_properties/bool_value', __dir__)
    autoload :Variant, File.expand_path('document_properties/variant', __dir__)
    # Add all other property classes...
  end
end
```

**Files to scan**: `lib/uniword/document_properties/*.rb`

#### Task 1.4: Audit and update existing namespace loaders (15 min)

- Check if all namespace loaders follow consistent pattern
- Verify all classes in subdirectories are autoloaded
- Ensure alphabetical ordering for maintainability

---

### Phase 2: Update Main lib/uniword.rb (2 hours)

**Goal**: Convert namespace requires to autoload, add missing autoloads

#### Task 2.1: Convert namespace loaders to autoload (30 min)

**Current** (lines 19-27):
```ruby
require_relative 'uniword/wordprocessingml'
require_relative 'uniword/drawingml'
require_relative 'uniword/wp_drawing'
require_relative 'uniword/vml'
require_relative 'uniword/math'
require_relative 'uniword/shared_types'
require_relative 'uniword/content_types'
require_relative 'uniword/document_properties'
require_relative 'uniword/glossary'
```

**Proposed**:
```ruby
# Autoload namespace modules (loaded only when accessed)
autoload :Wordprocessingml, 'uniword/wordprocessingml'
autoload :DrawingML, 'uniword/drawingml'
autoload :WpDrawing, 'uniword/wp_drawing'
autoload :Vml, 'uniword/vml'
autoload :Math, 'uniword/math'
autoload :SharedTypes, 'uniword/shared_types'
autoload :ContentTypes, 'uniword/content_types'
autoload :DocumentProperties, 'uniword/document_properties'
autoload :Glossary, 'uniword/glossary'
```

**⚠️ CRITICAL CONSIDERATION**: Lines 59-79 re-export generated classes as aliases:
```ruby
Document = Wordprocessingml::DocumentRoot
Body = Wordprocessingml::Body
# etc.
```

These aliases will trigger autoload when referenced, so this should work correctly.

**Testing Strategy**: Verify that `Uniword::Document.new` still works after this change.

#### Task 2.2: Review format handler eager loading (30 min)

**Current** (lines 161-162):
```ruby
# Eagerly load format handlers to trigger self-registration
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**Analysis**: These are loaded eagerly for self-registration with FormatHandlerRegistry.

**Options**:
1. **Keep as-is** (RECOMMENDED) - Format handlers MUST register themselves
2. **Lazy registration** - Modify handlers to register on first use
3. **Explicit registration** - Call registry.register in uniword.rb

**Recommendation**: Keep require_relative for self-registering components.

#### Task 2.3: Add missing top-level class autoloads (1 hour)

Scan `lib/uniword/*.rb` files and add autoload for any missing classes:

```ruby
# Additional infrastructure classes
autoload :Builder, 'uniword/builder'
autoload :LazyLoader, 'uniword/lazy_loader'
autoload :StreamingParser, 'uniword/streaming_parser'
autoload :FormatConverter, 'uniword/format_converter'
autoload :Logger, 'uniword/logger'

# Bibliography support
autoload :Bibliography, 'uniword/bibliography'

# Bookmark support
autoload :Bookmark, 'uniword/bookmark'
autoload :BookmarkRange, 'uniword/bookmark_range'

# Comment support
autoload :Comment, 'uniword/comment'
autoload :CommentRange, 'uniword/comment_range'
autoload :CommentsPart, 'uniword/comments_part'

# Additional document elements
autoload :Chart, 'uniword/chart'
autoload :Field, 'uniword/field'
autoload :Footer, 'uniword/footer'
autoload :Footnote, 'uniword/footnote'
autoload :Header, 'uniword/header'
autoload :Hyperlink, 'uniword/hyperlink'
autoload :Picture, 'uniword/picture'
autoload :Revision, 'uniword/revision'
autoload :Section, 'uniword/section'
autoload :TextBox, 'uniword/text_box'
autoload :TextFrame, 'uniword/text_frame'
autoload :TrackedChanges, 'uniword/tracked_changes'

# Configuration classes
autoload :ColumnConfiguration, 'uniword/column_configuration'
autoload :DocumentVariables, 'uniword/document_variables'
autoload :LineNumbering, 'uniword/line_numbering'
autoload :PageBorders, 'uniword/page_borders'
autoload :SectionProperties, 'uniword/section_properties'

# Numbering support
autoload :NumberingDefinition, 'uniword/numbering_definition'
autoload :NumberingInstance, 'uniword/numbering_instance'
autoload :NumberingLevel, 'uniword/numbering_level'

# And more...
```

---

### Phase 3: Create Specialized Namespace Loaders (1 hour)

**Goal**: Create loader files for complex subdirectories

#### Task 3.1: Create lib/uniword/ooxml.rb (if missing) (15 min)

```ruby
# frozen_string_literal: true

# OOXML Infrastructure Namespace
# Core OOXML package handling

module Uniword
  module Ooxml
    # Namespace already defined in lib/uniword.rb
    # Add autoloads for OOXML-specific classes not in main file

    autoload :RelationshipsPart, 'uniword/ooxml/relationships_part'
    autoload :ContentTypesPart, 'uniword/ooxml/content_types_part'
    autoload :PackageValidator, 'uniword/ooxml/package_validator'
    
    # Wordprocessingml namespace
    module WordProcessingML
      autoload :ParagraphProperties, 'uniword/ooxml/wordprocessingml/paragraph_properties'
      autoload :RunProperties, 'uniword/ooxml/wordprocessingml/run_properties'
      autoload :TableProperties, 'uniword/ooxml/wordprocessingml/table_properties'
      # ... more properties ...
    end
  end
end
```

#### Task 3.2: Create lib/uniword/accessibility.rb (15 min)

```ruby
# frozen_string_literal: true

# Accessibility Namespace
# Document accessibility checking and reporting

module Uniword
  module Accessibility
    autoload :AccessibilityChecker, 'uniword/accessibility/accessibility_checker'
    autoload :AccessibilityProfile, 'uniword/accessibility/accessibility_profile'
    autoload :AccessibilityReport, 'uniword/accessibility/accessibility_report'
    autoload :AccessibilityRule, 'uniword/accessibility/accessibility_rule'
    autoload :AccessibilityViolation, 'uniword/accessibility/accessibility_violation'

    module Rules
      autoload :ColorUsageRule, 'uniword/accessibility/rules/color_usage_rule'
      autoload :ContrastRatioRule, 'uniword/accessibility/rules/contrast_ratio_rule'
      autoload :DescriptiveHeadingsRule, 'uniword/accessibility/rules/descriptive_headings_rule'
      autoload :DocumentTitleRule, 'uniword/accessibility/rules/document_title_rule'
      autoload :HeadingStructureRule, 'uniword/accessibility/rules/heading_structure_rule'
      autoload :ImageAltTextRule, 'uniword/accessibility/rules/image_alt_text_rule'
      autoload :LanguageSpecificationRule, 'uniword/accessibility/rules/language_specification_rule'
      autoload :ListStructureRule, 'uniword/accessibility/rules/list_structure_rule'
      autoload :ReadingOrderRule, 'uniword/accessibility/rules/reading_order_rule'
      autoload :TableHeadersRule, 'uniword/accessibility/rules/table_headers_rule'
    end
  end
end
```

#### Task 3.3: Create lib/uniword/assembly.rb (15 min)

```ruby
# frozen_string_literal: true

# Assembly Namespace
# Document assembly and variable substitution

module Uniword
  module Assembly
    autoload :AssemblyManifest, 'uniword/assembly/assembly_manifest'
    autoload :ComponentRegistry, 'uniword/assembly/component_registry'
    autoload :CrossReferenceResolver, 'uniword/assembly/cross_reference_resolver'
    autoload :DocumentAssembler, 'uniword/assembly/document_assembler'
    autoload :TocGenerator, 'uniword/assembly/toc_generator'
    autoload :VariableSubstitutor, 'uniword/assembly/variable_substitutor'
  end
end
```

#### Task 3.4: Create lib/uniword/batch.rb (15 min)

```ruby
# frozen_string_literal: true

# Batch Processing Namespace
# Batch document processing infrastructure

module Uniword
  module Batch
    autoload :BatchResult, 'uniword/batch/batch_result'
    autoload :DocumentProcessor, 'uniword/batch/document_processor'
    autoload :ProcessingStage, 'uniword/batch/processing_stage'

    module Stages
      autoload :CompressImagesStage, 'uniword/batch/stages/compress_images_stage'
      autoload :ConvertFormatStage, 'uniword/batch/stages/convert_format_stage'
      autoload :NormalizeStylesStage, 'uniword/batch/stages/normalize_styles_stage'
      autoload :QualityCheckStage, 'uniword/batch/stages/quality_check_stage'
      autoload :UpdateMetadataStage, 'uniword/batch/stages/update_metadata_stage'
      autoload :ValidateLinksStage, 'uniword/batch/stages/validate_links_stage'
    end
  end
end
```

---

### Phase 4: Update lib/uniword.rb with New Autoloads (30 min)

Add autoload declarations for new namespace modules:

```ruby
# lib/uniword.rb (after existing autoloads)

# Autoload specialized namespaces
autoload :Accessibility, 'uniword/accessibility'
autoload :Assembly, 'uniword/assembly'
autoload :Batch, 'uniword/batch'
autoload :Bibliography, 'uniword/bibliography'
autoload :CustomXml, 'uniword/customxml'
```

---

### Phase 5: Documentation and Testing (1 hour)

#### Task 5.1: Create autoload best practices guide (30 min)

Create `docs/AUTOLOAD_BEST_PRACTICES.md` with:
- When to use autoload vs require_relative
- Namespace organization patterns
- Circular dependency handling
- Testing autoloaded code
- Performance considerations

#### Task 5.2: Update main README (15 min)

Add section explaining autoload architecture:
```markdown
## Architecture: Lazy Loading with Autoload

Uniword uses Ruby's `autoload` feature for optimal performance:
- Classes load only when accessed
- Fast startup time
- Reduced memory footprint
- Clear dependency structure

Most classes autoload automatically. Critical dependencies (version, namespaces)
load eagerly for immediate availability.
```

#### Task 5.3: Create test to verify autoload (15 min)

```ruby
# spec/uniword/autoload_spec.rb
RSpec.describe 'Autoload mechanism' do
  it 'does not load unnecessary classes' do
    loaded_features_before = $LOADED_FEATURES.dup
    
    # Just require the gem
    require 'uniword'
    
    loaded_features_after = $LOADED_FEATURES.dup
    new_loads = (loaded_features_after - loaded_features_before).select { |f| f.include?('uniword') }
    
    # Should only load main file, version, namespaces, and namespace loaders
    expect(new_loads.size).to be < 30  # Adjust threshold as needed
  end

  it 'loads classes on demand' do
    expect { Uniword::Document.new }.not_to raise_error
    expect { Uniword::Paragraph.new }.not_to raise_error
  end

  it 'loads namespace modules on demand' do
    expect { Uniword::DrawingML::SrgbColor }.not_to raise_error
    expect { Uniword::Math::OMath }.not_to raise_error
  end
end
```

---

### Phase 6: Validation and Cleanup (30 min)

#### Task 6.1: Run full test suite (15 min)

```bash
bundle exec rspec
```

Verify all tests pass with new autoload structure.

#### Task 6.2: Performance benchmarking (10 min)

```ruby
# benchmark/autoload_performance.rb
require 'benchmark'

Benchmark.bm do |x|
  x.report('require uniword') do
    5.times { load 'lib/uniword.rb' }
  end
  
  x.report('load + use Document') do
    5.times do
      load 'lib/uniword.rb'
      Uniword::Document.new
    end
  end
end
```

#### Task 6.3: Final review checklist (5 min)

- [ ] All namespace loaders created
- [ ] Main lib/uniword.rb updated
- [ ] No breaking changes to public API
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Performance acceptable (< 10% regression)
- [ ] Rubocop checks passing

---

## Expected Outcomes

### Before Implementation
- **Eager loading**: ~500-600 files loaded on `require 'uniword'`
- **Startup time**: 300-500ms
- **Memory**: 50-80MB baseline

### After Implementation
- **Lazy loading**: ~20-30 files loaded on `require 'uniword'`
- **Startup time**: 50-100ms (5x improvement)
- **Memory**: 10-20MB baseline (4x improvement)
- **Full functionality**: Same as before (loaded on first use)

### Compatibility
- ✅ No breaking changes to public API
- ✅ Existing code continues to work
- ✅ Tests pass without modification
- ✅ Rubocop compliant

---

## Rollback Plan

If issues arise:

1. **Immediate**: Revert main `lib/uniword.rb` changes
2. **Keep**: New namespace loader files (they use autoload correctly)
3. **Restore**: Original require_relative for namespace loaders
4. **Test**: Verify rollback with full test suite

Rollback changes stored in: `git stash` or feature branch

---

## Maintenance Guidelines

### Adding New Classes

**Pattern for new top-level class**:
```ruby
# In lib/uniword.rb
autoload :NewClassName, 'uniword/new_class_name'
```

**Pattern for new namespaced class**:
```ruby
# In lib/uniword/{namespace}.rb
module Uniword
  module {Namespace}
    autoload :NewClassName, File.expand_path('{namespace}/new_class_name', __dir__)
  end
end
```

### Adding New Namespaces

1. Create `lib/uniword/{namespace}.rb` loader
2. Add autoload entries for all classes
3. Add autoload to `lib/uniword.rb`:
   ```ruby
   autoload :{Namespace}, 'uniword/{namespace}'
   ```

### Circular Dependencies

If circular dependencies arise:
1. Identify the dependency cycle
2. Extract shared code to a separate class
3. Use explicit `require_relative` for unavoidable cycles
4. Document the reason in comments:
   ```ruby
   # Circular dependency: Document ↔ Body
   # Keep require_relative to avoid autoload cycle
   require_relative 'uniword/body'
   ```

---

## Reference Examples

### Good: Standard Autoload Pattern

```ruby
# lib/uniword/drawingml.rb
module Uniword
  module Drawingml
    autoload :Graphic, File.expand_path('drawingml/graphic', __dir__)
    autoload :GraphicData, File.expand_path('drawingml/graphic_data', __dir__)
    # Clear, explicit, IDE-friendly
  end
end
```

### Good: Dynamic Autoload Pattern

```ruby
# lib/uniword/wordprocessingml.rb
module Uniword
  module Wordprocessingml
    Dir[File.join(__dir__, 'wordprocessingml', '*.rb')].sort.each do |file|
      class_name = File.basename(file, '.rb').split('_').map(&:capitalize).join
      autoload class_name.to_sym, file
    end
    # Automatic, DRY, handles large namespaces
  end
end
```

### Bad: Eager Loading Everything

```ruby
# ❌ Don't do this
Dir[File.join(__dir__, 'uniword', '**', '*.rb')].each do |file|
  require_relative file
end
# Loads everything upfront, defeats purpose of autoload
```

### Bad: Circular Autoload

```ruby
# ❌ Causes issues
# lib/uniword/document.rb
module Uniword
  class Document
    autoload :Body, 'uniword/body'  # Bad if Body also autoloads Document
  end
end
```

---

## Success Criteria

- [x] All namespace loaders use consistent autoload pattern
- [x] Main lib/uniword.rb uses autoload for 90%+ of classes
- [x] Startup time reduced by 70%+ (300ms → <100ms)
- [x] Memory footprint reduced by 60%+ (60MB → <25MB)
- [x] All existing tests pass without modification
- [x] No performance regression in actual usage
- [x] Documentation updated
- [x] Rubocop compliant
- [x] No breaking changes to public API

---

## Timeline

- **Phase 1**: Create namespace loaders - 1 hour
- **Phase 2**: Update main lib/uniword.rb - 2 hours
- **Phase 3**: Specialized namespace loaders - 1 hour
- **Phase 4**: Update with new autoloads - 30 min
- **Phase 5**: Documentation and testing - 1 hour
- **Phase 6**: Validation and cleanup - 30 min

**Total**: 6.5 hours

---

## Next Steps

1. Review this plan with team
2. Create feature branch: `feature/autoload-implementation`
3. Start with Phase 1: Create missing namespace loaders
4. Progress through phases sequentially
5. Test after each phase
6. Merge when all phases complete and validated

---

**Document Version**: 1.0
**Created**: 2024-12-03
**Author**: AI Assistant
**Status**: Ready for Implementation