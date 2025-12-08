# Round-Trip Phase A: Fix RunProperties Serialization

**Goal**: Fix empty `<rPr>` elements to achieve 270-272/274 tests
**Current**: 266/274 (97.1%)
**Target**: 270-272/274 (98.5-99.3%)
**Duration**: 1.5-2 hours
**Priority**: 🔴 CRITICAL

---

## Objective

Fix the root cause of ~80% of glossary test failures: `<rPr>` elements serializing as empty instead of with child elements (fonts, size, etc.).

---

## Problem Statement

### Current Behavior (WRONG)

```xml
<w:r>
  <w:rPr/>  <!-- Empty! Should have child elements -->
  <w:t>Some text</w:t>
</w:r>
```

### Expected Behavior (CORRECT)

```xml
<w:r>
  <w:rPr>
    <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
    <w:sz w:val="22"/>
    <w:color w:val="000000"/>
  </w:rPr>
  <w:t>Some text</w:t>
</w:r>
```

### Impact

6 of 8 failing tests are primarily caused by this issue:
- Bibliographies.dotx (12 differences)
- Cover Pages.dotx (24 differences)
- Footers.dotx (191 differences - also has VML)
- Headers.dotx (227 differences - also has VML)
- Table of Contents.dotx (18 differences)
- Tables.dotx (125 differences)

---

## Investigation Steps

### Step A1: Investigate RunProperties (30 min)

**Goal**: Understand why `<rPr>` serializes empty

#### Task 1: Check RunProperties Class (10 min)

<read_file>
<args>
<file>
<path>lib/uniword/wordprocessingml/run_properties.rb</path>
</file>
</args>
</read_file>

**Check**:
1. Are `fonts`, `size`, `color` attributes defined? ✅ (should be yes)
2. Are xml mappings correct for these attributes?
3. Is `mixed_content` set? ✅ (should be yes)
4. Are `render_nil: false` settings correct?

#### Task 2: Check FontFamily (RunFonts) (10 min)

<read_file>
<args>
<file>
<path>lib/uniword/properties/run_fonts.rb</path>
</file>
</args>
</read_file>

**Check**:
1. Are `ascii`, `h_ansi`, `cs`, `east_asia` attributes defined?
2. Are xml mappings using `map_attribute` (not `map_element`)?
3. Is element name `'rFonts'` (not `'run_fonts'`)?

#### Task 3: Check FontSize (10 min)

<read_file>
<args>
<file>
<path>lib/uniword/properties/font_size.rb</path>
</file>
</args>
</read_file>

**Check**:
1. Is `value` attribute defined?
2. Is xml mapping using `map_attribute 'val'`?
3. Is element name `'sz'`?

#### Task 4: Test Current Serialization (10 min)

**Extract glossary XML to see actual output**:

```bash
cd /Users/mulgogi/src/mn/uniword

# Create test script
cat > /tmp/test_run_properties.rb << 'EOF'
require './lib/uniword'

# Create RunProperties with fonts and size
props = Uniword::Wordprocessingml::RunProperties.new
props.fonts = Uniword::Properties::RunFonts.new(
  ascii: 'Calibri',
  h_ansi: 'Calibri'
)
props.size = Uniword::Properties::FontSize.new(value: 22)

# Serialize
puts "XML Output:"
puts props.to_xml(pretty: true)
EOF

# Run test
ruby /tmp/test_run_properties.rb
```

**Expected Output**:
```xml
<w:rPr>
  <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
  <w:sz w:val="22"/>
</w:rPr>
```

**If Output Shows Empty `<w:rPr/>`**: Problem confirmed in serialization

---

## Implementation Steps

### Step A2: Fix RunProperties Class (45 min)

Based on investigation, likely issues:

#### Issue 1: FontFamily Not Serializing

**Hypothesis**: `fonts` attribute not properly initialized or mapped

**Check  1**: Ensure Pattern 0 compliance

```ruby
# lib/uniword/wordprocessingml/run_properties.rb

class RunProperties < Lutaml::Model::Serializable
  # ✅ ATTRIBUTES MUST COME FIRST (Pattern 0)
  attribute :fonts, Properties::RunFonts
  attribute :size, Properties::FontSize
  attribute :color, Properties::ColorValue
  # ... other attributes

  # ✅ XML MAPPINGS COME AFTER
  xml do
    element 'rPr'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content

    # Check these mappings
    map_element 'rFonts', to: :fonts, render_nil: false
    map_element 'sz', to: :size, render_nil: false
    map_element 'color', to: :color, render_nil: false
  end
end
```

**Check 2**: Verify initialization doesn't override parsed values

```ruby
def initialize(attrs = {})
  super
  # ❌ WRONG: @fonts = nil  # This would override parsed value!
  # ✅ CORRECT: @fonts ||= nil  # Only set if not already set
end
```

**Fix if Needed**:

<edit_file>
<target_file>lib/uniword/wordprocessingml/run_properties.rb</target_file>
<instructions>Fix RunProperties to ensure fonts, size, and color serialize correctly. Ensure Pattern 0 compliance and proper initialization.</instructions>
<code_edit>
# If initialization is overriding parsed values, fix it:

def initialize(attrs = {})
  super
  # Use ||= instead of = for all properties that might be parsed
  @fonts ||= nil  # Don't override if already set by parser
  @size ||= nil
  @color ||= nil
  # ... other properties
end