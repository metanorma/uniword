# Round-Trip Implementation Plan for Uniword

## Executive Summary

Based on testing with the ISO 8601 documents, we have identified specific round-trip issues that need to be addressed to achieve perfect document round-trip functionality in Uniword.

## Test Results Analysis

### Test Document Results

1. **iso-wd-8601-2-2026.docx** (295KB)
   - **Status**: ❌ FAILED - XML parsing error
   - **Issue**: `Failed to parse QName 'w:m:oMath'` - Math equation namespace conflict
   - **Content**: 2,399 paragraphs, 31 tables, 4 images, 506 hyperlinks, 252 styles
   - **Unknown Elements**: 66 (mostly bookmarkStart/bookmarkEnd)

2. **document.doc** (985KB MHTML)
   - **Status**: ✅ PARTIAL SUCCESS - Content preserved but significant size loss
   - **Issue**: 92.7% file size reduction (985KB → 72KB)
   - **Content**: 2,339 paragraphs, 31 tables, 0 images, 0 hyperlinks, 13 styles
   - **Unknown Elements**: 0

### Key Issues Identified

1. **Math Equation Support**: XML namespace parsing fails on `w:m:oMath` elements
2. **MHTML to DOCX Conversion**: Massive data loss during format conversion
3. **Bookmark Handling**: bookmarkStart/bookmarkEnd elements not properly supported
4. **Missing OOXML Elements**: Several document elements not in current schema

## Current Infrastructure Assessment

### ✅ Strengths
- [`UnknownElement`](lib/uniword/unknown_element.rb:36) class properly implemented
- [`OoxmlDeserializer`](lib/uniword/serialization/ooxml_deserializer.rb:1056) supports unknown element preservation
- [`OoxmlSerializer`](lib/uniword/serialization/ooxml_serializer.rb:109) properly serializes unknown elements
- Warning collection system integrated

### ❌ Gaps
- Math equation namespace support missing
- Bookmark elements should be known, not unknown
- MHTML format handler needs improvement
- XML namespace handling needs enhancement

## Implementation Plan

### Phase 1: Fix Critical XML Parsing Issues (High Priority)

#### 1.1 Add Math Equation Namespace Support
**Target**: Fix `w:m:oMath` parsing errors

```ruby
# lib/uniword/serialization/ooxml_deserializer.rb
NAMESPACES = {
  'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
  'm' => 'http://schemas.openxmlformats.org/officeDocument/2006/math',  # ADD THIS
  'wp' => 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
  # ... existing namespaces
}.freeze
```

#### 1.2 Implement Bookmark Support
**Target**: Convert bookmarkStart/bookmarkEnd from unknown to known elements

**Files to create:**
- `lib/uniword/bookmark_start.rb`
- `lib/uniword/bookmark_end.rb`

**Updates needed:**
- Add to [`KNOWN_PARAGRAPH_ELEMENTS`](lib/uniword/serialization/ooxml_deserializer.rb:26)
- Implement parsing in [`parse_paragraph`](lib/uniword/serialization/ooxml_deserializer.rb:230)
- Add serialization support in [`OoxmlSerializer`](lib/uniword/serialization/ooxml_serializer.rb:130)

#### 1.3 Enhanced XML Namespace Handling
**Target**: Robust namespace prefix handling for complex documents

### Phase 2: MHTML Format Handler Improvements (Medium Priority)

#### 2.1 Preserve MHTML-specific Content
**Target**: Reduce data loss in MHTML → DOCX conversion

Current issue: 92.7% size reduction indicates massive content loss

**Root cause analysis needed:**
- What content is being dropped?
- Are embedded images/styles being lost?
- Is text formatting being simplified?

#### 2.2 Enhanced MHTML Parser
**Files to review:**
- `lib/uniword/infrastructure/mime_parser.rb`
- `lib/uniword/formats/mhtml_handler.rb`

### Phase 3: Schema Expansion (Medium Priority)

#### 3.1 Complete Office Math Support
**Target**: Full math equation round-trip

**New elements to add:**
- `m:oMath` - Math equation container
- `m:oMathPara` - Math paragraph
- `m:r` - Math run
- `m:t` - Math text

#### 3.2 Document Structure Elements
**Target**: Support sectPr, fldChar, instrText properly

### Phase 4: Perfect Round-Trip Validation (Low Priority)

#### 4.1 Byte-Level Comparison Tests
**Target**: Detect any data loss

#### 4.2 Schema Coverage Analysis
**Target**: Ensure 100% element coverage

## Implementation Tasks

### Task 1: Fix Math Namespace Issue

```ruby
# lib/uniword/serialization/ooxml_deserializer.rb
# Add to NAMESPACES constant:
'm' => 'http://schemas.openxmlformats.org/officeDocument/2006/math'

# Update XML parsing to handle prefixed namespaces better
def create_unknown_element(node, context:)
  # Handle namespace prefix properly for math elements
  full_name = if node.namespace&.prefix
    "#{node.namespace.prefix}:#{node.name}"
  else
    node.name
  end

  # Rest of implementation...
end
```

### Task 2: Implement Bookmark Elements

```ruby
# lib/uniword/bookmark_marker.rb
class BookmarkMarker < Element
  attribute :bookmark_id, :string
  attribute :name, :string
  attribute :col_first, :integer
  attribute :col_last, :integer
end

class BookmarkStart < BookmarkMarker
  xml do
    root 'bookmarkStart'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    map_attribute 'id', to: :bookmark_id
    map_attribute 'name', to: :name
    map_attribute 'colFirst', to: :col_first
    map_attribute 'colLast', to: :col_last
  end
end

class BookmarkEnd < BookmarkMarker
  xml do
    root 'bookmarkEnd'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    map_attribute 'id', to: :bookmark_id
  end
end
```

### Task 3: Enhanced MHTML Analysis

```ruby
# Create diagnostic script to analyze MHTML content loss
# lib/uniword/diagnostics/mhtml_analyzer.rb
class MhtmlAnalyzer
  def analyze_content_loss(original_path, roundtrip_path)
    # Detailed analysis of what's being lost
  end
end
```

## Testing Strategy

### Round-Trip Test Suite

```ruby
# spec/round_trip/perfect_round_trip_spec.rb
RSpec.describe 'Perfect Round-Trip' do
  context 'with ISO 8601 documents' do
    it 'preserves DOCX math equations' do
      # Test math equation preservation
    end

    it 'preserves MHTML formatting' do
      # Test MHTML format conversion
    end

    it 'handles bookmark elements' do
      # Test bookmark round-trip
    end
  end
end
```

## Success Criteria

1. **DOCX with Math**: Perfect round-trip without XML parsing errors
2. **MHTML Conversion**: < 5% file size difference in conversion
3. **Element Coverage**: All document elements either supported or preserved as UnknownElement
4. **Automated Tests**: Comprehensive test suite for round-trip validation

## Timeline

- **Week 1**: Fix math namespace and bookmark support
- **Week 2**: Enhance MHTML format handler
- **Week 3**: Complete testing and validation
- **Week 4**: Documentation and integration

## Files to Modify

### Core Files
- [`lib/uniword/serialization/ooxml_deserializer.rb`](lib/uniword/serialization/ooxml_deserializer.rb:35) - Add math namespace
- [`lib/uniword/serialization/ooxml_serializer.rb`](lib/uniword/serialization/ooxml_serializer.rb:130) - Add bookmark serialization

### New Files
- `lib/uniword/bookmark_start.rb`
- `lib/uniword/bookmark_end.rb`
- `lib/uniword/math_element.rb`
- `spec/round_trip/perfect_round_trip_spec.rb`

### Enhanced Files
- `lib/uniword/formats/mhtml_handler.rb` - Improve MHTML preservation
- `lib/uniword/infrastructure/mime_parser.rb` - Better MIME parsing

This implementation plan addresses the specific issues found in testing and provides a clear path to perfect round-trip functionality.