# Uniword: Full Autoload Migration - Session 2 Start

**Context**: Converting all `require_relative` to `autoload` for maintenance simplification
**Current Status**: Session 1 complete (3/9 namespaces autoloaded)
**Next**: Session 2 - Complete main file autoload conversion
**Duration**: ~2 hours

---

## Quick Start

```bash
cd /Users/mulgogi/src/mn/uniword
git checkout feature/autoload-migration  # Or create if needed
bundle install
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb  # Verify baseline
```

---

## Session 2 Overview

**Goal**: Convert ALL `lib/uniword.rb` to use autoload (except critical requires)

**Tasks**:
1. Remove 6 namespace require_relative statements (convert to autoload)
2. Add ~50 missing top-level class autoloads
3. Keep format handler require_relative (with comments)
4. Convert constant assignments to class methods

**Expected Outcome**:
- `lib/uniword.rb` uses autoload for all classes
- Only 3 require_relative remain (version, namespaces, format handlers)
- All 84 tests still passing
- API compatibility maintained via methods

---

## Task 2.1: Convert Namespace require_relative (15 min)

### Step 1: Backup Current File

```bash
cp lib/uniword.rb lib/uniword.rb.session2_backup
```

### Step 2: Find and Replace (Lines 18-30)

**FIND** (exact match):
```ruby
# Load namespaces required for immediate constant assignments (lines 59-79) and cross-dependencies
# These MUST be eagerly loaded due to extensive dependency chains.
# Analysis shows deep cross-dependencies between core namespaces that prevent autoloading.
require_relative 'uniword/wordprocessingml'  # Used: Document, Body, Paragraph, Run, Table, etc.
require_relative 'uniword/wp_drawing'        # Required by: Wordprocessingml::Drawing
require_relative 'uniword/drawingml'         # Required by: WpDrawing::Inline
require_relative 'uniword/vml'               # Required by: Wordprocessingml classes (Pict, etc.)
require_relative 'uniword/math'              # Used: MathElement = Math::OMath
require_relative 'uniword/shared_types'      # Required by: Multiple namespace property classes

# Autoload remaining namespace modules (loaded only when accessed)
# These provide ~33% autoload coverage for namespace modules (3/9)
autoload :ContentTypes, 'uniword/content_types'
autoload :DocumentProperties, 'uniword/document_properties'
autoload :Glossary, 'uniword/glossary'
```

**REPLACE WITH**:
```ruby
# Autoload all namespace modules for maintenance simplicity
# Strategy: Declarative loading reduces dependency tracking burden
autoload :Wordprocessingml, 'uniword/wordprocessingml'
autoload :WpDrawing, 'uniword/wp_drawing'
autoload :DrawingML, 'uniword/drawingml'
autoload :Vml, 'uniword/vml'
autoload :Math, 'uniword/math'
autoload :SharedTypes, 'uniword/shared_types'
autoload :ContentTypes, 'uniword/content_types'
autoload :DocumentProperties, 'uniword/document_properties'
autoload :Glossary, 'uniword/glossary'
```

### Step 3: Verify Syntax

```bash
ruby -c lib/uniword.rb
```

**CHECKPOINT**: File syntax is valid

---

## Task 2.2: Convert Constant Assignments to Methods (1 hour)

**Critical**: This enables autoload by deferring class resolution

### Step 1: Find Constants Section (Lines 56-79)

**FIND** (exact match):
```ruby
module Uniword
  # Re-export generated classes as primary API
  # These are the schema-generated classes from lib/uniword/wordprocessingml/
  Document = Wordprocessingml::DocumentRoot
  Body = Wordprocessingml::Body
  Paragraph = Wordprocessingml::Paragraph
  Run = Wordprocessingml::Run
  Table = Wordprocessingml::Table
  TableRow = Wordprocessingml::TableRow
  TableCell = Wordprocessingml::TableCell

  # Properties classes
  ParagraphProperties = Ooxml::WordProcessingML::ParagraphProperties
  RunProperties = Ooxml::WordProcessingML::RunProperties
  TableProperties = Ooxml::WordProcessingML::TableProperties
  SectionProperties = Wordprocessingml::SectionProperties

  # Additional element classes
  Hyperlink = Wordprocessingml::Hyperlink
  BookmarkStart = Wordprocessingml::BookmarkStart
  BookmarkEnd = Wordprocessingml::BookmarkEnd

  # Math support
  MathElement = Math::OMath
```

**REPLACE WITH**:
```ruby
module Uniword
  # Re-export generated classes as primary API (lazy evaluation via methods)
  # These are the schema-generated classes from lib/uniword/wordprocessingml/
  # Using class methods instead of constants enables autoload while maintaining API compatibility
  class << self
    # Document structure classes
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
```

### Step 2: Test API Compatibility

```bash
bundle exec ruby -e "
require './lib/uniword'
puts 'Testing API compatibility...'
puts 'Document class: ' + Uniword::Document.to_s
doc = Uniword::Document.new
puts 'Document.new works: ' + doc.class.to_s
puts 'SUCCESS: API compatible'
"
```

**Expected Output**:
```
Testing API compatibility...
Document class: Uniword::Wordprocessingml::DocumentRoot
Document.new works: Uniword::Wordprocessingml::DocumentRoot
SUCCESS: API compatible
```

**CHECKPOINT**: API compatibility verified

---

## Task 2.3: Add Top-Level Class Autoloads (40 min)

### Step 1: Generate Autoload List

```bash
cd lib/uniword
ls *.rb | grep -v "^uniword.rb$" | while read file; do
  base=$(basename "$file" .rb)
  class_name=$(echo "$base" | ruby -e 'puts ARGF.read.split("_").map(&:capitalize).join')
  echo "autoload :$class_name, 'uniword/$base'"
done | sort > /tmp/top_level_autoloads.txt

cat /tmp/top_level_autoloads.txt
```

### Step 2: Add to lib/uniword.rb

**Location**: After existing autoloads (around line 120, after CLI autoload)

**Insert**:
```ruby
# === Top-Level Classes (Comprehensive) ===
# All classes in lib/uniword/*.rb use autoload for maintenance simplicity

# Infrastructure Classes
autoload :Builder, 'uniword/builder'
autoload :ElementRegistry, 'uniword/element_registry'
autoload :LazyLoader, 'uniword/lazy_loader'
autoload :StreamingParser, 'uniword/streaming_parser'
autoload :FormatConverter, 'uniword/format_converter'
autoload :Logger, 'uniword/logger'

# Document Structure Elements
autoload :Bookmark, 'uniword/bookmark'
autoload :Chart, 'uniword/chart'
autoload :ColorScheme, 'uniword/color_scheme'
autoload :ColumnConfiguration, 'uniword/column_configuration'
autoload :Comment, 'uniword/comment'
autoload :CommentRange, 'uniword/comment_range'
autoload :CommentsPart, 'uniword/comments_part'
autoload :DocumentVariables, 'uniword/document_variables'
autoload :Endnote, 'uniword/endnote'
autoload :Extension, 'uniword/extension'
autoload :ExtensionList, 'uniword/extension_list'
autoload :ExtraColorSchemeList, 'uniword/extra_color_scheme_list'
autoload :Field, 'uniword/field'
autoload :FontScheme, 'uniword/font_scheme'
autoload :Footer, 'uniword/footer'
autoload :Footnote, 'uniword/footnote'
autoload :FormatScheme, 'uniword/format_scheme'
autoload :Header, 'uniword/header'
autoload :Image, 'uniword/image'
autoload :LineNumbering, 'uniword/line_numbering'
autoload :MathEquation, 'uniword/math_equation'
autoload :NumberingDefinition, 'uniword/numbering_definition'
autoload :NumberingInstance, 'uniword/numbering_instance'
autoload :NumberingLevel, 'uniword/numbering_level'
autoload :ObjectDefaults, 'uniword/object_defaults'
autoload :PageBorders, 'uniword/page_borders'
autoload :ParagraphBorder, 'uniword/paragraph_border'
autoload :Picture, 'uniword/picture'
autoload :Revision, 'uniword/revision'
autoload :Section, 'uniword/section'
autoload :SectionProperties, 'uniword/section_properties'
autoload :Shading, 'uniword/shading'
autoload :TabStop, 'uniword/tab_stop'
autoload :TableBorder, 'uniword/table_border'
autoload :TableCell, 'uniword/table_cell'
autoload :TableColumn, 'uniword/table_column'
autoload :TextBox, 'uniword/text_box'
autoload :TextFrame, 'uniword/text_frame'
autoload :TrackedChanges, 'uniword/tracked_changes'

# Add any other classes found in lib/uniword/*.rb
```

**Note**: Verify each file exists before adding autoload. Skip files that don't exist.

### Step 3: Verify Added Autoloads

```bash
# Count autoloads in main file
grep "autoload :" lib/uniword.rb | wc -l
# Expected: ~60+ (was ~40, now ~100+)

# Verify syntax
ruby -c lib/uniword.rb
```

**CHECKPOINT**: All top-level classes have autoload statements

---

## Task 2.4: Document Format Handler Exception (5 min)

### Update Format Handler Section (Lines 161-162)

**FIND**:
```ruby
# Eagerly load format handlers to trigger self-registration
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**REPLACE WITH**:
```ruby
# Eagerly load format handlers to trigger self-registration
# NOTE: These MUST use require_relative (not autoload) because:
# 1. Format handlers self-register with FormatHandlerRegistry on load
# 2. Registration happens via class-level code execution (side effect)
# 3. Autoload would defer registration until first use
# This is the ONLY acceptable use of require_relative for non-base files
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**CHECKPOINT**: Exception documented clearly

---

## Final Validation (10 min)

### Step 1: Run Full Test Suite

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
```

**Expected**: 84/84 tests passing

### Step 2: Test Autoload Functionality

```bash
bundle exec ruby -e "
require './lib/uniword'
puts 'Files loaded initially: ' + \$LOADED_FEATURES.grep(/uniword/).size.to_s

# Access a class to trigger autoload
Uniword::DrawingML::SrgbColor

puts 'Files loaded after access: ' + \$LOADED_FEATURES.grep(/uniword/).size.to_s
puts 'Autoload working: files loaded on demand'
"
```

### Step 3: Verify API Still Works

```bash
bundle exec ruby -e "
require './lib/uniword'
doc = Uniword::Document.new
para = Uniword::Paragraph.new
puts 'API compatibility: SUCCESS'
"
```

### Step 4: Count require_relative

```bash
grep "require_relative" lib/uniword.rb | grep -v "^#" | wc -l
```

**Expected**: 3 (version, namespaces, 2 format handlers)

---

## Success Criteria

- [ ] All namespace loaders use autoload (9/9)
- [ ] All top-level classes have autoload (~50+)
- [ ] Only 3 require_relative remain
- [ ] All 84 tests passing
- [ ] API compatibility maintained
- [ ] Autoload functionality verified

---

## Commit Changes

```bash
git add lib/uniword.rb lib/uniword.rb.session2_backup
git commit -m "feat(autoload): Session 2 - Complete main file autoload conversion

- Converted all 9 namespace modules to autoload
- Added ~50 top-level class autoloads
- Converted constant assignments to class methods
- Maintained API compatibility via method-based access
- Only 3 require_relative remain (version, namespaces, format handlers)

Changes:
- lib/uniword.rb: Complete autoload migration
- All 84 tests passing
- Zero breaking changes
- Maintenance burden significantly reduced

Autoload coverage: 33% → 90%"
```

---

## Troubleshooting

### Issue: Tests Fail After Conversion

**Solution**: Check that class methods work correctly

```bash
bundle exec ruby -e "
require './lib/uniword'
puts Uniword::Document
puts Uniword::Document.new
"
```

### Issue: Method Missing Errors

**Solution**: Verify autoload paths are correct

```bash
# Check file exists
ls lib/uniword/builder.rb

# Check autoload statement
grep "autoload :Builder" lib/uniword.rb
```

### Issue: Constant Not Found

**Solution**: Use method syntax instead of constant syntax

```ruby
# Before (constant)
Uniword::Document

# After (method)
Uniword.Document  # or Uniword::Document (both work)
```

---

## Next Steps

After Session 2 complete:
1. Proceed to Session 3 (Create specialized namespace loaders)
2. Run `bundle exec rspec` to verify all tests
3. Update implementation status document

---

**Document Ready**: Session 2 implementation guide
**Estimated Time**: 2 hours
**Prerequisites**: Session 1 complete
**Branch**: feature/autoload-migration