# Phase 5 Session 1: AlternateContent Implementation
**Goal**: Achieve 270-271/274 tests passing (from 266/274)
**Duration**: 4 hours
**Priority**: HIGH - Critical for 100% round-trip

## Context

You are starting Phase 5 to achieve **100% round-trip fidelity (274/274 tests)**. Currently at 266/274 (97.1%). All 8 failing tests are glossary round-trip tests in `spec/uniword/document_elements_roundtrip_spec.rb`.

Phase 4 is complete (27 Wordprocessingml properties including 13 SDT properties). The failures are due to **missing Wordprocessingml elements**, not SDT properties.

## Current State

**Test Results**:
- StyleSets: 168/168 (100%) ✅
- Themes: 174/174 (100%) ✅
- Document Elements Content Types: 8/8 (100%) ✅
- Document Elements Glossary: 0/8 (0%) ❌
- **Total**: 266/274 (97.1%)

**Failing Tests** (all in same category):
1. Bibliographies.dotx - glossary round-trip
2. Cover Pages.dotx - glossary round-trip
3. Equations.dotx - glossary round-trip
4. Footers.dotx - glossary round-trip
5. Headers.dotx - glossary round-trip
6. Table of Contents.dotx - glossary round-trip
7. Tables.dotx - glossary round-trip
8. Watermarks.dotx - glossary round-trip

## Session 1 Mission: Implement AlternateContent

**Why**: Analysis shows AlternateContent elements (`<mc:AlternateContent>`) appear in 4-5 of the 8 failing tests. This single fix could resolve 50-62% of failures.

**What**: Create complete AlternateContent support with Choice and Fallback elements.

**Expected**: 270-271/274 tests passing after this session (98-99%)

## Task Breakdown

### Task 1: Create MarkupCompatibility Namespace (15 min)

**File**: `lib/uniword/ooxml/namespaces.rb`

**Add**:
```ruby
class MarkupCompatibility < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/markup-compatibility/2006'
  prefix_default 'mc'
  element_form_default :qualified
end
```

**Verify**: Class is accessible as `Uniword::Ooxml::Namespaces::MarkupCompatibility`

### Task 2: Create AlternateContent Model (60 min)

**File**: `lib/uniword/wordprocessingml/alternate_content.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class AlternateContent < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :choice, Choice
      attribute :fallback, Fallback, default: nil
      
      xml do
        root 'AlternateContent'
        namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        mixed_content
        
        map_element 'Choice', to: :choice
        map_element 'Fallback', to: :fallback, render_nil: false
      end
    end
  end
end
```

**File**: `lib/uniword/wordprocessingml/choice.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class Choice < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :requires, :string
      attribute :content, :string
      
      xml do
        root 'Choice'
        namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        mixed_content
        
        map_attribute 'Requires', to: :requires
        map_content to: :content
      end
    end
  end
end
```

**File**: `lib/uniword/wordprocessingml/fallback.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class Fallback < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :content, :string
      
      xml do
        root 'Fallback'
        namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
        mixed_content
        
        map_content to: :content
      end
    end
  end
end
```

**Add Autoloads**: `lib/uniword/wordprocessingml.rb`

```ruby
autoload :AlternateContent, 'uniword/wordprocessingml/alternate_content'
autoload :Choice, 'uniword/wordprocessingml/choice'
autoload :Fallback, 'uniword/wordprocessingml/fallback'
```

### Task 3: Integrate AlternateContent (90 min)

**Files to Modify** (4 files):

#### 3.1: `lib/uniword/paragraph.rb`

Add attribute and mapping:
```ruby
attribute :alternate_content, Wordprocessingml::AlternateContent, default: nil

xml do
  # ... existing mappings ...
  map_element 'AlternateContent', to: :alternate_content,
              namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
              render_nil: false
end
```

#### 3.2: `lib/uniword/run.rb`

Same pattern as Paragraph.

#### 3.3: `lib/uniword/table.rb`

Same pattern as Paragraph.

#### 3.4: `lib/uniword/wordprocessingml/sdt_content.rb`

Same pattern as Paragraph.

**CRITICAL**: Follow Pattern 0 - attribute BEFORE xml block in ALL files.

### Task 4: Create Tests (75 min)

**File**: `spec/uniword/wordprocessingml/alternate_content_spec.rb`

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::AlternateContent do
  describe 'serialization' do
    it 'serializes with Choice only' do
      ac = described_class.new
      ac.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>test</wps:wsp>'
      )
      
      xml = ac.to_xml
      expect(xml).to include('<mc:AlternateContent')
      expect(xml).to include('<mc:Choice')
      expect(xml).to include('Requires="wps"')
    end
    
    it 'serializes with Choice and Fallback' do
      ac = described_class.new
      ac.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>modern</wps:wsp>'
      )
      ac.fallback = Uniword::Wordprocessingml::Fallback.new(
        content: '<v:shape>legacy</v:shape>'
      )
      
      xml = ac.to_xml
      expect(xml).to include('<mc:AlternateContent')
      expect(xml).to include('<mc:Choice')
      expect(xml).to include('<mc:Fallback')
    end
  end
  
  describe 'deserialization' do
    it 'parses from XML' do
      xml = <<~XML
        <mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <mc:Choice Requires="wps">
            <wps:wsp>test</wps:wsp>
          </mc:Choice>
        </mc:AlternateContent>
      XML
      
      ac = described_class.from_xml(xml)
      expect(ac.choice).to be_a(Uniword::Wordprocessingml::Choice)
      expect(ac.choice.requires).to eq('wps')
    end
    
    it 'parses with Fallback' do
      xml = <<~XML
        <mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <mc:Choice Requires="wps">
            <wps:wsp>modern</wps:wsp>
          </mc:Choice>
          <mc:Fallback>
            <v:shape>legacy</v:shape>
          </mc:Fallback>
        </mc:AlternateContent>
      XML
      
      ac = described_class.from_xml(xml)
      expect(ac.fallback).to be_a(Uniword::Wordprocessingml::Fallback)
    end
  end
  
  describe 'round-trip' do
    it 'preserves structure through serialization' do
      original = described_class.new
      original.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>content</wps:wsp>'
      )
      
      xml = original.to_xml
      parsed = described_class.from_xml(xml)
      
      expect(parsed.choice.requires).to eq(original.choice.requires)
    end
  end
end
```

### Task 5: Test and Verify (60 min)

**Step 5.1**: Run unit tests
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/wordprocessingml/alternate_content_spec.rb
```

**Expected**: All AlternateContent tests passing

**Step 5.2**: Run baseline tests
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb
```

**Expected**: 342/342 still passing (zero regressions)

**Step 5.3**: Run document elements tests
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation
```

**Expected**: 12-13/16 passing (up from 8/16)
- Content Types: 8/8 (same)
- Glossary: 4-5/8 (improved from 0/8)

**Step 5.4**: Calculate total
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb \
                   spec/uniword/document_elements_roundtrip_spec.rb \
                   --format progress 2>&1 | grep -E "(examples|failures)"
```

**Expected**: 270-271/274 passing (98-99%)

## Success Criteria

- [ ] MarkupCompatibility namespace created
- [ ] AlternateContent + Choice + Fallback classes created
- [ ] All 4 integration points updated (Paragraph, Run, Table, SdtContent)
- [ ] AlternateContent unit tests all passing
- [ ] Zero baseline regressions (342/342 maintained)
- [ ] 4-5 glossary tests now passing (up from 0)
- [ ] Total: 270-271/274 tests passing

## If Success Criteria Not Met

**If less than 270/274**:
1. Extract actual XML from one failing test
2. Compare with AlternateContent implementation
3. Identify structure mismatch
4. Fix implementation
5. Re-test

**Do NOT proceed to Session 2** until hitting 270/274 target.

## Architecture Reminders

**Pattern 0 (CRITICAL)**:
```ruby
# ✅ CORRECT
attribute :my_attr, MyType
xml do
  map_element 'elem', to: :my_attr
end

# ❌ WRONG - Will not serialize
xml do
  map_element 'elem', to: :my_attr
end
attribute :my_attr, MyType
```

**MECE**: Clear separation - AlternateContent is separate from SDT/Paragraph/Run

**Model-Driven**: No raw XML storage - proper classes for all elements

**Open/Closed**: Easy to extend - add to integration points as needed

## Troubleshooting

### Issue: Namespace not found

**Solution**: Check `lib/uniword/ooxml/namespaces.rb` has MarkupCompatibility class

### Issue: Choice/Fallback not serializing

**Solution**: Check Pattern 0 - attributes before xml block

### Issue: Content not preserved

**Solution**: Ensure `mixed_content` directive in xml block

### Issue: Tests still failing at same rate

**Solution**: Extract actual XML from failing test, compare structure

## Next Steps

After achieving 270-271/274:
1. Document Session 1 results
2. Create Session 2 prompt (Complete RunProperties)
3. Target: 271-272/274 after Session 2
4. Final: 274/274 after Session 3

## Time Check

- Task 1 (Namespace): 15 min
- Task 2 (Models): 60 min = 1:15 total
- Task 3 (Integration): 90 min = 2:45 total
- Task 4 (Tests): 75 min = 4:00 total
- Task 5 (Verify): 60 min = 5:00 total

**If running over 4 hours**: Skip some test variations in Task 4, focus on getting glossary tests passing.

**Remember**: Quality over speed, but we need 270/274 to proceed!

Good luck! 🎯