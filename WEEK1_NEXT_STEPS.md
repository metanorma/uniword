# Week 1 Round-Trip Continuation Plan

## Date
2025-11-15

## Current Status

### ✅ COMPLETED: Type-Level Namespace Refactoring
- CoreProperties refactored with 9 Type classes
- Type classes use `xml_namespace` for automatic namespace propagation
- Zero hardcoded `namespace:` parameters in map_element
- **docProps/core.xml**: ✅ Canon test PASSING
- Pattern documented in [`WEEK1_TYPE_NAMESPACE_COMPLETE.md`](WEEK1_TYPE_NAMESPACE_COMPLETE.md)

### ❌ REMAINING: 12 Round-Trip Tests Failing
Current test status: **2/13 passing** (core.xml + webSettings.xml)

## Remaining Work

### Priority 1: Fix docProps/app.xml (15 minutes)

**Current Issue**: Element ordering and statistics differences

**File**: [`lib/uniword/ooxml/app_properties.rb`](lib/uniword/ooxml/app_properties.rb)

**Required Changes**:
1. Add `render_nil: true` to Company element mapping (line ~42)
2. Verify element ordering matches OOXML spec
3. Consider if document statistics recalculation is acceptable behavior

**Expected Result**: docProps/app.xml passes Canon test

### Priority 2: Analyze Remaining Failures (30 minutes)

Run detailed analysis of each failing file:

```bash
bundle exec rspec spec/uniword/ooxml/complete_roundtrip_spec.rb --format json > analysis.json
```

**Files to investigate**:
1. `[Content_Types].xml` - Content type registration issues
2. `_rels/.rels` - Relationship ordering/IDs
3. `word/document.xml` - Main document content issues
4. `word/styles.xml` - Style preservation
5. `word/fontTable.xml` - Font definitions
6. `word/settings.xml` - Document settings
7. `word/numbering.xml` - Numbering definitions
8. `word/_rels/document.xml.rels` - Document relationships
9. `word/theme/theme1.xml` - Theme (empty document issue)
10. `word/theme/_rels/theme1.xml.rels` - Theme relationships

**For each file**, determine:
- Is it a missing class/model issue?
- Is it a serialization issue?
- Is it an element ordering issue?
- Is it acceptable variance (statistics, IDs)?

### Priority 3: Quick Wins (60 minutes)

**Likely fixes**:

1. **Relationship IDs** (`_rels/.rels`, `word/_rels/document.xml.rels`)
   - May need ID normalization in XmlNormalizers
   - IDs like rId1, rId2, rId3 are arbitrary

2. **Empty documents** (`word/theme/theme1.xml`)
   - Currently returns empty/nil
   - Need proper Theme serialization or skip if not present

3. **Element ordering issues**
   - Many OOXML files have specific element order requirements
   - May need explicit ordering in xml blocks

### Priority 4: Major Missing Classes (2-4 hours)

These likely require new OOXML Model classes:

1. **Settings** ([`word/settings.xml`](lib/uniword/ooxml/settings.rb) if exists)
   - Document zoom, compatibility settings
   - Math properties, theme font language
   - Shape defaults, color scheme mapping

2. **Numbering** ([`word/numbering.xml`](lib/uniword/numbering_*.rb))
   - Abstract numbering definitions
   - Numbering instances
   - Already have some models, may need enhancement

3. **Content Types** (`[Content_Types].xml`)
   - Default content types by extension
   - Override content types by part name
   - Ordering and completeness issues

## Implementation Strategy

### Step 1: Quick Investigation (30 min)
Run each failing test individually and capture exact differences:

```ruby
require 'canon/pretty_printer/xml'
pp = Canon::PrettyPrinter::Xml.new(indent: 2)

# For each failing file:
original = extract_file(source, file)
roundtrip = extract_file(output, file)

puts "=== Original ==="
puts pp.format(original)
puts "\n=== Round-trip ==="
puts pp.format(roundtrip)
```

### Step 2: Categorize Issues (30 min)
Group failures by type:
- **Normalization needed** (statistics, IDs, ordering)
- **Missing features** (classes, properties)
- **Serialization bugs** (incorrect XML generation)

### Step 3: Fix in Batches (2-3 hours)
1. **Batch A**: Normalization fixes (add to XmlNormalizers)
2. **Batch B**: Element ordering fixes (update xml blocks)
3. **Batch C**: Missing classes (create new OOXML models)

## Success Criteria

✅ **Minimum Goal (Week 1)**:
- docProps/core.xml passing ✅ **ACHIEVED**
- docProps/app.xml passing (in progress)

✅ **Stretch Goal**:
- 10/13 tests passing (acceptable failures for complex files)
- All docProps files passing
- Relationship files passing

## Temporary Workarounds

Document any necessary workarounds in [`spec/support/xml_normalizers.rb`](spec/support/xml_normalizers.rb):

```ruby
module XmlNormalizers
  # Normalize timestamps (+00:00 → Z)
  def self.normalize_timestamps(xml)
    # ... existing ...
  end

  # Normalize statistics (recalculated values acceptable)
  def self.normalize_statistics(xml)
    # Replace <Pages>X</Pages> etc with canonical values
  end

  # Normalize relationship IDs (arbitrary)
  def self.normalize_relationship_ids(xml)
    # Renumber rId1, rId2, rId3 consistently
  end

  # Remove unused namespace declarations
  def self.remove_unused_namespaces(xml, namespaces)
    # ... existing ...
  end
end
```

## Estimated Timeline

- **docProps/app.xml fix**: 15 minutes
- **Analysis of remaining files**: 30 minutes
- **Quick wins (normalizations)**: 60 minutes
- **Major missing classes**: 2-4 hours
- **Testing and validation**: 30 minutes

**Total**: 4-6 hours for comprehensive round-trip support

## Next Session Prompt

**Context**: Week 1 Type-level namespace refactoring complete. CoreProperties uses Type classes with xml_namespace declarations. docProps/core.xml passes Canon test. Now need to fix remaining 11 round-trip failures.

**Start with**:
1. Read [`WEEK1_TYPE_NAMESPACE_COMPLETE.md`](WEEK1_TYPE_NAMESPACE_COMPLETE.md) for what's done
2. Read [`WEEK1_NEXT_STEPS.md`](WEEK1_NEXT_STEPS.md) (this file) for remaining work
3. Fix docProps/app.xml Company element rendering
4. Run analysis on remaining failures
5. Implement fixes in priority order

**Test Command**:
```bash
bundle exec rspec spec/uniword/ooxml/complete_roundtrip_spec.rb --format documentation
```

**Goal**: Achieve 10+/13 tests passing with focus on docProps files first.