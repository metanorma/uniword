# Phase 5: Achieve 100% Round-Trip Fidelity
**Goal**: 274/274 tests passing (100%)
**Current**: 266/274 tests passing (97.1%)
**Gap**: 8 failing glossary tests
**Timeline**: COMPRESSED - 8-10 hours total

## Executive Summary

We need to fix 8 failing glossary round-trip tests to achieve 100%. Analysis shows these failures are NOT due to missing SDT properties (Phase 4 complete). They require **specific Wordprocessingml elements** that are currently missing.

## Root Cause Analysis

All 8 failures are in the same test category:
- **File**: `spec/uniword/document_elements_roundtrip_spec.rb`
- **Test**: "round-trips [filename] glossary document"
- **Files**: Bibliographies, Cover Pages, Equations, Footers, Headers, Table of Contents, Tables, Watermarks

**Common Issues Across All 8 Failures**:

1. **Missing AlternateContent** - Office uses `<mc:AlternateContent>` for version compatibility
2. **Incomplete run properties** - Missing `<w:rPr>` child elements in SDT content
3. **Element ordering** - Some elements serialize in wrong order (need `ordered: true`)
4. **Missing paragraph properties** - Additional `<w:pPr>` elements

## Implementation Strategy

### Session 1: AlternateContent (4 hours) ⏳

**Priority**: HIGH - This single fix could resolve 4-5 of the 8 failures

#### 1.1 Create AlternateContent Model (60 min)

**Files to Create**:
```
lib/uniword/wordprocessingml/alternate_content.rb
lib/uniword/wordprocessingml/choice.rb  
lib/uniword/wordprocessingml/fallback.rb
```

**AlternateContent Structure**:
```ruby
# lib/uniword/wordprocessingml/alternate_content.rb
class AlternateContent < Lutaml::Model::Serializable
  attribute :choice, Choice                    # Required
  attribute :fallback, Fallback, default: nil  # Optional
  
  xml do
    root 'AlternateContent'
    namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
    mixed_content
    map_element 'Choice', to: :choice
    map_element 'Fallback', to: :fallback
  end
end
```

**Choice Structure**:
```ruby
# lib/uniword/wordprocessingml/choice.rb
class Choice < Lutaml::Model::Serializable
  attribute :requires, :string              # Required (e.g., "wps")
  attribute :content, :string               # Mixed content
  
  xml do
    root 'Choice'
    namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
    mixed_content
    map_attribute 'Requires', to: :requires
    map_content to: :content
  end
end
```

**Fallback Structure**:
```ruby
# lib/uniword/wordprocessingml/fallback.rb  
class Fallback < Lutaml::Model::Serializable
  attribute :content, :string
  
  xml do
    root 'Fallback'
    namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
    mixed_content
    map_content to: :content
  end
end
```

#### 1.2 Create MarkupCompatibility Namespace (15 min)

**File**: `lib/uniword/ooxml/namespaces.rb`

```ruby
module Uniword
  module Ooxml
    module Namespaces
      class MarkupCompatibility < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/markup-compatibility/2006'
        prefix_default 'mc'
        element_form_default :qualified
      end
    end
  end
end
```

#### 1.3 Integrate AlternateContent (90 min)

**Files to Modify**:
- `lib/uniword/paragraph.rb` - Add alternate_content attribute
- `lib/uniword/run.rb` - Add alternate_content attribute
- `lib/uniword/table.rb` - Add alternate_content attribute
- `lib/uniword/wordprocessingml/sdt_content.rb` - Add alternate_content support

**Integration Pattern**:
```ruby
# In each class (Paragraph, Run, Table, SdtContent)
attribute :alternate_content, AlternateContent, default: nil

xml do
  # ... existing mappings
  map_element 'AlternateContent', to: :alternate_content,
              namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
              render_nil: false
end
```

#### 1.4 Test AlternateContent (75 min)

**Create**: `spec/uniword/wordprocessingml/alternate_content_spec.rb`

```ruby
RSpec.describe Uniword::Wordprocessingml::AlternateContent do
  describe 'serialization' do
    it 'serializes with Choice and Fallback' do
      ac = described_class.new
      ac.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<pict>...</pict>'
      )
      ac.fallback = Uniword::Wordprocessingml::Fallback.new(
        content: '<v:shapetype>...</v:shapetype>'
      )
      
      xml = ac.to_xml
      expect(xml).to include('<mc:AlternateContent')
      expect(xml).to include('<mc:Choice Requires="wps"')
      expect(xml).to include('<mc:Fallback')
    end
  end
  
  describe 'deserialization' do
    it 'parses from XML' do
      xml = <<~XML
        <mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <mc:Choice Requires="wps">
            <pict>...</pict>
          </mc:Choice>
          <mc:Fallback>
            <v:shapetype>...</v:shapetype>
          </mc:Fallback>
        </mc:AlternateContent>
      XML
      
      ac = described_class.from_xml(xml)
      expect(ac.choice.requires).to eq('wps')
      expect(ac.fallback).not_to be_nil
    end
  end
end
```

**Run Tests**:
```bash
bundle exec rspec spec/uniword/wordprocessingml/alternate_content_spec.rb
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb
# Expected: 4-5 more tests passing (270-271/274)
```

### Session 2: Complete Run Properties (2 hours) ⏳

**Priority**: HIGH - Missing `<w:rPr>` elements in SDT content

#### 2.1 Identify Missing RunProperties Children (30 min)

**Action**: Extract and compare `<w:rPr>` elements from failing tests

**Command**:
```bash
cd /Users/mulgogi/src/mn/uniword
for file in references/word-resources/document-elements/*.dotx; do
  unzip -q "$file" -d tmp_extract
  echo "=== $(basename "$file") ==="
  grep -A 20 '<w:rPr>' tmp_extract/word/glossary/document.xml | head -30
  rm -rf tmp_extract
done > missing_rpr_elements.txt
```

#### 2.2 Implement Missing Elements (60 min)

**Likely Missing**:
- `<w:rStyle>` - Character style reference
- `<w:lang>` - Language (already exists but needs integration)
- `<w:eastAsiaLayout>` - Asian typography
- `<w:fitText>` - Fit text
- `<w:bCs>` - Complex script bold
- `<w:iCs>` - Complex script italic

**Pattern** (for each):
```ruby
# lib/uniword/wordprocessingml/run_properties.rb
attribute :r_style, RStyle, default: nil
attribute :east_asia_layout, EastAsiaLayout, default: nil
# ... etc

xml do
  # ... existing
  map_element 'rStyle', to: :r_style, render_nil: false
  map_element 'eastAsiaLayout', to: :east_asia_layout, render_nil: false
end
```

#### 2.3 Test Run Properties (30 min)

```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb
# Expected: 1-2 more tests passing (271-272/274)
```

### Session 3: Element Ordering & Final Fixes (2 hours) ⏳

**Priority**: MEDIUM - Ordering and cleanup

#### 3.1 Add `ordered: true` to Classes (60 min)

**Files to Check**:
```ruby
# lib/uniword/glossary/doc_part_body.rb
xml do
  root 'docPartBody'  
  namespace Uniword::Ooxml::Namespaces::WordProcessingML
  ordered true  # ADD THIS
  
  map_element 'p', to: :paragraphs
  map_element 'tbl', to: :tables
  map_element 'sdt', to: :sdts
end
```

**Check These Classes**:
- `DocPartBody`
- `Paragraph` (if elements order matters)
- `SdtContent`
- `Table`

#### 3.2 Run Full Test Suite (30 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb \
                   spec/uniword/document_elements_roundtrip_spec.rb

# Expected: 274/274 (100%) ✅
```

#### 3.3 Final Cleanup & Documentation (30 min)

- Update UNIWORD_ROUNDTRIP_STATUS.md
- Update README.adoc with 100% achievement
- Archive Phase 5 temporary docs
- Update memory bank

## Compressed Timeline

**Total**: 8 hours (compressed from 10)

| Session | Time | Deliverable | Tests Expected |
|---------|------|-------------|----------------|
| **Session 1** | 4 hours | AlternateContent complete | 270-271/274 (98-99%) |
| **Session 2** | 2 hours | Complete RunProperties | 271-272/274 (99%) |
| **Session 3** | 2 hours | Element ordering + cleanup | 274/274 (100%) ✅ |

## Success Criteria

- [ ] 274/274 tests passing (100%)
- [ ] Zero baseline regressions (342/342 maintained)
- [ ] All 8 glossary tests fixed
- [ ] Pattern 0 compliance (100%)
- [ ] MECE architecture maintained
- [ ] Documentation updated

## Risk Mitigation

### High Risk: AlternateContent Complexity

**Risk**: AlternateContent may have nested structures we don't fully understand

**Mitigation**:
1. Extract actual XML from failing tests FIRST
2. Create minimal reproduction case
3. Iterate on structure until it works
4. Don't proceed to Session 2 until at least 270/274 passing

### Medium Risk: Unknown RunProperties Elements

**Risk**: May discover more missing `<w:rPr>` children than expected

**Mitigation**:
1. Systematic extraction and analysis (Session 2.1)
2. Implement only what's actually present in test files
3. Use `render_nil: false` for all optional elements
4. Don't guess - implement based on actual XML

### Low Risk: Element Ordering

**Risk**: Adding `ordered: true` may break other tests

**Mitigation**:
1. Test after each change
2. Only add where element order matters
3. Can be reverted quickly if needed

## Architecture Principles (NON-NEGOTIABLE)

1. **Pattern 0**: Attributes BEFORE xml mappings (ALWAYS)
2. **MECE**: Clear separation of concerns
3. **Model-Driven**: No raw XML storage
4. **Open/Closed**: Extensible design
5. **Single Responsibility**: Each class one purpose

## Quality Standards (NON-NEGOTIABLE)

1. **No shortcuts** - Proper model classes for all elements
2. **No threshold lowering** - 100% means 100%
3. **No hacks** - Correct architecture only
4. **Zero regressions** - 342/342 baseline must remain passing
5. **Complete testing** - Test after each change

## Next Steps

1. **Begin Session 1** - AlternateContent implementation
2. **Target**: 270-271/274 tests after Session 1 (4 hours)
3. **Checkpoint**: If not hitting 270/274 after Session 1, investigate before proceeding
4. **Final Goal**: 274/274 (100%) after Session 3

## Expected Outcome

After 8 hours of focused work:
- ✅ 274/274 tests passing (100%)
- ✅ Complete round-trip fidelity for all 61 files
- ✅ Ready for v1.1.0 release with 100% guarantee
- ✅ No known limitations

**Let's achieve 100%!** 🎯