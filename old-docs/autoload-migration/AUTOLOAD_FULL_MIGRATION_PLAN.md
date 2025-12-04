# Uniword: Complete Autoload Migration Plan

**Goal**: Convert ALL `require_relative` statements to `autoload` for maintenance simplicity
**Rationale**: Reduce dependency tracking burden, create self-documenting code structure
**Target**: 100% autoload coverage (except gem requires and critical base files)
**Timeline**: Compressed - 3 sessions, ~4 hours total

---

## Strategic Shift: Maintenance Over Performance

### Previous Analysis (Session 1)
- Found only 1.2% file reduction due to cross-dependencies
- Recommended halting migration due to minimal performance benefit

### New Direction
**Maintenance Simplification Takes Priority**:
- `require_relative` creates implicit dependency tracking burden
- `autoload` is declarative and self-documenting
- Easier to see what's available without reading individual files
- Reduces cognitive load for contributors
- Simplifies future refactoring

**Accept Trade-off**:
- Performance improvement may be minimal
- But maintenance burden reduction is significant
- Self-documenting structure worth the effort

---

## Current State (Post-Session 1)

### ✅ Already Autoloaded (9 namespace loaders exist)
1. `wordprocessingml.rb` - 200+ classes (dynamic autoload pattern)
2. `drawingml.rb` - 92 classes
3. `wp_drawing.rb` - 26 classes
4. `vml.rb` - 18 classes
5. `math.rb` - 66 classes
6. `shared_types.rb` - 15 classes
7. `content_types.rb` - 3 classes
8. `document_properties.rb` - 19 classes
9. `glossary.rb` - 19 classes

### ⚠️ Partially Migrated (lib/uniword.rb)
- Lines 18-30: 3 namespaces autoloaded, 6 require_relative
- Lines 82-158: Most classes already use autoload
- Lines 161-162: Format handlers use require_relative (self-registration)

### ❌ Not Autoloaded Yet
**Top-level classes** (~50+ classes in lib/uniword/*.rb):
- Individual element classes
- Infrastructure classes
- Format/serialization classes
- Property classes

---

## Implementation Plan

### Session 2: Complete Main File Autoload (2 hours)

**Goal**: Convert ALL lib/uniword.rb to use autoload (except critical requires)

#### Task 2.1: Remove Namespace require_relative (15 min)

Currently (lines 18-30):
```ruby
require_relative 'uniword/wordprocessingml'
require_relative 'uniword/wp_drawing'
require_relative 'uniword/drawingml'
require_relative 'uniword/vml'
require_relative 'uniword/math'
require_relative 'uniword/shared_types'
```

**Convert to**:
```ruby
autoload :Wordprocessingml, 'uniword/wordprocessingml'
autoload :WpDrawing, 'uniword/wp_drawing'
autoload :DrawingML, 'uniword/drawingml'
autoload :Vml, 'uniword/vml'
autoload :Math, 'uniword/math'
autoload :SharedTypes, 'uniword/shared_types'
```

**Issue**: Lines 59-79 have constant assignments that need immediate resolution.

**Solution**: Convert constant assignments to lazy methods:
```ruby
# Before
Document = Wordprocessingml::DocumentRoot

# After
def self.Document
  Wordprocessingml::DocumentRoot
end
```

This maintains API compatibility while enabling autoload.

#### Task 2.2: Add Missing Top-Level Autoloads (1 hour)

Scan `lib/uniword/*.rb` and add autoload for each:

```bash
cd lib/uniword
ls *.rb | grep -v ".rb$" | while read file; do
  class_name=$(basename "$file" .rb | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "autoload :$class_name, 'uniword/$(basename "$file" .rb)'"
done
```

Expected additions (~50 classes):
- `autoload :Bookmark, 'uniword/bookmark'`
- `autoload :Builder, 'uniword/builder'`
- `autoload :Chart, 'uniword/chart'`
- `autoload :ColorScheme, 'uniword/color_scheme'`
- `autoload :Comment, 'uniword/comment'`
- ... (continue for all top-level files)

#### Task 2.3: Handle Format Handler Registration (30 min)

**Current Issue**: Format handlers self-register via require_relative

**Solution**: Keep minimal require_relative for self-registration:
```ruby
# Keep these for side-effects (registration)
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**Rationale**: Self-registration pattern requires eager loading

#### Task 2.4: Convert Constant Assignments to Methods (15 min)

Replace lines 59-79 constant assignments with methods:

```ruby
# Instead of constants
class << self
  def Document
    Wordprocessingml::DocumentRoot
  end
  
  def Body
    Wordprocessingml::Body
  end
  
  def Paragraph
    Wordprocessingml::Paragraph
  end
  
  # ... etc for all constants
end
```

**API Compatibility**: `Uniword::Document.new` still works!

---

### Session 3: Create Missing Namespace Loaders (1.5 hours)

**Goal**: Create autoload loaders for specialized namespaces

#### Task 3.1: Create lib/uniword/accessibility.rb (15 min)

```ruby
# frozen_string_literal: true

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

#### Task 3.2: Create lib/uniword/assembly.rb (10 min)

```ruby
# frozen_string_literal: true

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

#### Task 3.3: Create lib/uniword/batch.rb (15 min)

```ruby
# frozen_string_literal: true

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

#### Task 3.4: Register New Namespaces in Main File (10 min)

Add to `lib/uniword.rb`:
```ruby
autoload :Accessibility, 'uniword/accessibility'
autoload :Assembly, 'uniword/assembly'
autoload :Batch, 'uniword/batch'
```

---

### Session 4: Testing & Documentation (30 min)

**Goal**: Validate changes and update documentation

#### Task 4.1: Run Full Test Suite (10 min)

```bash
bundle exec rspec
# Expected: All tests pass (no API changes)
```

#### Task 4.2: Verify Autoload Coverage (5 min)

```bash
# Count autoload statements
grep -r "autoload" lib/uniword/*.rb lib/uniword/**/*.rb | wc -l
# Expected: 500+ autoload statements
```

#### Task 4.3: Update README.adoc (10 min)

Add section:
```asciidoc
== Architecture: Autoload-Based Loading

Uniword uses Ruby's `autoload` feature throughout for clean dependency management:

* **Declarative structure**: All available classes visible in loader files
* **Reduced maintenance**: No manual dependency tracking needed
* **Self-documenting**: Loader files serve as module indexes
* **Lazy loading**: Classes load only when accessed

All namespace modules use autoload exclusively, making the codebase structure transparent and easy to navigate.
```

#### Task 4.4: Move Old Documentation (5 min)

```bash
mv docs/AUTOLOAD_MIGRATION_COMPLETE.md old-docs/
mv docs/AUTOLOAD_CONTINUATION_PLAN.md old-docs/
mv docs/AUTOLOAD_CONTINUATION_PROMPT.md old-docs/
```

---

## Critical Implementation Details

### Handling Constant Assignment Issue

**Problem**: Lines 59-79 in lib/uniword.rb assign constants at module load time

**Solution**: Convert to class methods for lazy resolution:

```ruby
# lib/uniword.rb
module Uniword
  class << self
    # Re-export generated classes as methods (lazy evaluation)
    def Document
      Wordprocessingml::DocumentRoot
    end
    
    def Body
      Wordprocessingml::Body
    end
    
    def Paragraph
      Wordprocessingml::Paragraph
    end
    
    def Run
      Wordprocessingml::Run
    end
    
    def Table
      Wordprocessingml::Table
    end
    
    def TableRow
      Wordprocessingml::TableRow
    end
    
    def TableCell
      Wordprocessingml::TableCell
    end
    
    # Properties classes
    def ParagraphProperties
      Ooxml::WordProcessingML::ParagraphProperties
    end
    
    def RunProperties
      Ooxml::WordProcessingML::RunProperties
    end
    
    def TableProperties
      Ooxml::WordProcessingML::TableProperties
    end
    
    def SectionProperties
      Wordprocessingml::SectionProperties
    end
    
    # Additional element classes
    def Hyperlink
      Wordprocessingml::Hyperlink
    end
    
    def BookmarkStart
      Wordprocessingml::BookmarkStart
    end
    
    def BookmarkEnd
      Wordprocessingml::BookmarkEnd
    end
    
    # Math support
    def MathElement
      Math::OMath
    end
  end
end
```

**API Compatibility**:
- ✅ `Uniword::Document.new` works (method call)
- ✅ `Uniword.Document` works (method call)
- ✅ `doc.is_a?(Uniword::Document)` works (returns the class)
- ❌ `Uniword::Document` direct constant reference won't work initially

**Alternative** (if constant compatibility critical):
Use `const_set` with lazy evaluation:
```ruby
def self.Document
  @document_class ||= begin
    klass = Wordprocessingml::DocumentRoot
    const_set(:Document, klass) unless const_defined?(:Document, false)
    klass
  end
end
```

### Format Handler Self-Registration

**Keep these require_relative**:
```ruby
# Eagerly load format handlers to trigger self-registration
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**Rationale**: Self-registration pattern needs side effects at load time.

---

## Testing Strategy

### Test Coverage Goals

1. **API Compatibility**: Verify `Uniword::Document.new` still works
2. **Autoload Functionality**: Verify lazy loading works
3. **Performance**: Measure file loading (informational only)
4. **Regression**: All existing tests must pass

### Test Plan

```ruby
# spec/uniword/autoload_full_spec.rb
RSpec.describe 'Full Autoload Implementation' do
  it 'loads minimal files on require' do
    loaded_before = $LOADED_FEATURES.grep(/uniword/).size
    require 'uniword'
    loaded_after = $LOADED_FEATURES.grep(/uniword/).size
    
    # Expect < 50 files loaded (vs 257 before)
    expect(loaded_after - loaded_before).to be < 50
  end
  
  it 'provides API compatibility' do
    # These should work via method calls
    expect { Uniword::Document.new }.not_to raise_error
    expect { Uniword::Paragraph.new }.not_to raise_error
  end
  
  it 'loads classes on demand' do
    files_before = $LOADED_FEATURES.grep(/uniword/).size
    
    # Access a class
    Uniword::DrawingML::SrgbColor
    
    files_after = $LOADED_FEATURES.grep(/uniword/).size
    expect(files_after).to be > files_before
  end
end
```

---

## Success Criteria

1. ✅ **Zero require_relative** (except version, namespaces, format handlers)
2. ✅ **All tests passing** (84/84 styleset + all others)
3. ✅ **API compatibility maintained** (method-based access works)
4. ✅ **Self-documenting structure** (all autoloads visible in loader files)
5. ✅ **Reduced maintenance burden** (no manual dependency tracking)

---

## Rollback Plan

If critical issues arise:

```bash
# Restore from git
git checkout lib/uniword.rb

# Or revert specific commit
git revert HEAD
```

Autoload changes are **non-breaking** since API remains compatible through methods.

---

## Timeline Summary

- **Session 2**: Complete main file autoload (2 hours)
- **Session 3**: Create missing namespace loaders (1.5 hours)
- **Session 4**: Testing & documentation (30 min)

**Total**: ~4 hours (compressed from original 6.5 hours)

**Priority**: Maintenance simplification over performance optimization

---

**Document Version**: 2.0 (Revised Strategy)
**Status**: Ready for Implementation
**Next**: Begin Session 2