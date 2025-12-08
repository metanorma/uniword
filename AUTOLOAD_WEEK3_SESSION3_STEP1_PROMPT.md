# Autoload Week 3 Session 3 - Step 1: Fix XmlNamespace Error

**Created**: December 8, 2024
**Priority**: 🔴 CRITICAL
**Estimated Time**: 30-45 minutes
**Prerequisite**: Namespace consolidation (commit 66d971c) ✅ COMPLETE

---

## Objective

Fix the pre-existing `Lutaml::Model::XmlNamespace` NameError that prevents the library from loading.

---

## Current Error

```
NameError: uninitialized constant Lutaml::Model::XmlNamespace
  lib/uniword/ooxml/namespaces.rb:10:in `<module:Namespaces>'

class WordProcessingML < Lutaml::Model::XmlNamespace
                                      ^^^^^^^^^^^^^^
```

**File**: `lib/uniword/ooxml/namespaces.rb:10`
**Status**: Blocks all library loading
**Impact**: Cannot run tests, cannot use library

---

## Investigation Steps

### Step 1: Check lutaml-model API (10 min)

**Actions**:
1. Check if `Lutaml::Model::XmlNamespace` exists in lutaml-model
2. Review lutaml-model source at `/Users/mulgogi/src/lutaml/lutaml-model`
3. Check for API changes in recent versions
4. Look for namespace-related classes

**Commands**:
```bash
# Check lutaml-model source
cd /Users/mulgogi/src/lutaml/lutaml-model
grep -r "XmlNamespace" lib/

# Check if class exists
grep -r "class XmlNamespace" lib/

# Check namespace-related classes
grep -r "Namespace" lib/lutaml/model/ | head -20
```

### Step 2: Review Gemfile Dependencies (5 min)

**Check**:
```ruby
# Gemfile
gem 'lutaml-model', path: '/Users/mulgogi/src/lutaml/lutaml-model'
```

**Or**:
```ruby
gem 'lutaml-model', '~> 0.7'
```

**Action**: Verify version/path is correct

### Step 3: Check Namespace Usage Pattern (10 min)

**Current Code** (`lib/uniword/ooxml/namespaces.rb`):
```ruby
module Uniword
  module Ooxml
    module Namespaces
      class WordProcessingML < Lutaml::Model::XmlNamespace  # ← ERROR
        def self.uri
          'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        end
      end
      # ... more namespaces
    end
  end
end
```

**Questions**:
1. Is `XmlNamespace` the correct base class?
2. Has lutaml-model API changed?
3. Is there an alternative approach?

### Step 4: Determine Solution (10 min)

**Possible Solutions**:

**Option A**: Update lutaml-model version
- If XmlNamespace was removed/renamed
- Update Gemfile
- Bundle install

**Option B**: Use alternative namespace pattern
- Use simple Ruby constants instead of class hierarchy
- Example:
  ```ruby
  module Namespaces
    WORDPROCESSINGML = 'http://schemas.openxmlformats.org/...'
    DRAWINGML = 'http://schemas.openxmlformats.org/...'
    # etc.
  end
  ```

**Option C**: Use lutaml-model namespace helpers
- Check if lutaml-model provides namespace utilities
- Use proper lutaml-model API

**Option D**: Remove XmlNamespace inheritance
- Keep class structure but don't inherit
- Simpler approach if inheritance not needed

---

## Implementation

### If Option B (Most Likely)

**File**: `lib/uniword/ooxml/namespaces.rb`

**Current** (~50 lines with 10+ namespace classes):
```ruby
class WordProcessingML < Lutaml::Model::XmlNamespace
  def self.uri
    'http://...'
  end
end
```

**Replace With**:
```ruby
module Namespaces
  # WordprocessingML namespace (w:)
  WordProcessingML = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

  # DrawingML namespace (a:)
  DrawingML = 'http://schemas.openxmlformats.org/drawingml/2006/main'

  # Relationships namespace (r:)
  Relationships = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'

  # Math namespace (m:)
  MathML = 'http://schemas.openxmlformats.org/officeDocument/2006/math'

  # VML namespace (v:)
  VML = 'urn:schemas-microsoft-com:vml'

  # Office namespace (o:)
  VmlOffice = 'urn:schemas-microsoft-com:office:office'

  # Word Drawing namespace (wp:)
  WordprocessingDrawing = 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'

  # Picture namespace (pic:)
  Picture = 'http://schemas.openxmlformats.org/drawingml/2006/picture'

  # Extended Properties namespace (ep:)
  ExtendedProperties = 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties'

  # Core Properties namespace (cp:)
  CoreProperties = 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties'
end
```

**Update Pattern**:
1. Change class definitions to constants
2. Use direct string values (no `.uri` method needed)
3. Keep descriptive comments
4. Maintain same structure for easy reference

### Verification Commands

**Test Library Loading**:
```bash
cd /Users/mulgogi/src/mn/uniword
ruby -e "require './lib/uniword'" 2>&1 | head -20
```

**Expected**: No NameError, library loads successfully

**Test Baseline**:
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 spec/uniword/theme_roundtrip_spec.rb --format progress 2>&1 | tail -5
```

**Expected**: 258 examples, 177 failures (known baseline)

---

## Success Criteria

- [ ] Library loads without NameError
- [ ] `ruby -e "require './lib/uniword'"` succeeds
- [ ] Baseline tests run (258/258 executed)
- [ ] Known failures unchanged (177 failures expected)
- [ ] No new errors introduced
- [ ] Namespace constants accessible

---

## Testing Checklist

### Unit Tests
- [ ] Library loads: `ruby -e "require './lib/uniword'"`
- [ ] Namespace constants defined: `Uniword::Ooxml::Namespaces::WordProcessingML`
- [ ] Constants are strings: `"http://..."`

### Integration Tests
- [ ] Theme tests initialize: `bundle exec rspec spec/uniword/theme_roundtrip_spec.rb`
- [ ] StyleSet tests initialize: `bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb`
- [ ] Baseline maintained: 258 examples execute

### Namespace Usage Tests
Check that namespace constants are used correctly in:
- [ ] `lib/uniword/wordprocessingml/*.rb` files (xml blocks)
- [ ] `lib/uniword/drawingml/*.rb` files
- [ ] `lib/uniword/math/*.rb` files

Example usage:
```ruby
xml do
  root 'document'
  namespace Uniword::Ooxml::Namespaces::WordProcessingML  # Must work
end
```

---

## Files to Update

### Primary Fix
- `lib/uniword/ooxml/namespaces.rb` (1 file, ~50 lines)

### Verification (No Changes Expected)
These files use namespaces but shouldn't need updates:
- `lib/uniword/wordprocessingml/*.rb` (~93 files)
- `lib/uniword/drawingml/*.rb` (~200+ files)
- `lib/uniword/math/*.rb` (~50 files)
- `lib/uniword/wp_drawing/*.rb` (~30 files)

**Why No Updates**: They reference `Namespaces::WordProcessingML` constant, which will still exist as a constant instead of a class.

---

## Commit Message Template

```
fix(namespaces): replace XmlNamespace inheritance with constants

Replace class-based namespace definitions with simple constants.
Lutaml::Model::XmlNamespace was removed/unavailable in lutaml-model.

BEFORE:
class WordProcessingML < Lutaml::Model::XmlNamespace
  def self.uri
    'http://...'
  end
end

AFTER:
WordProcessingML = 'http://...'

This resolves NameError preventing library from loading.

Files changed: 1
- lib/uniword/ooxml/namespaces.rb (class → constant)

Issue: Fixes library loading blocker
```

---

## Time Tracking

| Task | Estimated | Actual |
|------|-----------|--------|
| Investigation | 10 min | |
| Review dependencies | 5 min | |
| Check usage pattern | 10 min | |
| Determine solution | 10 min | |
| Implement fix | 5 min | |
| Test library load | 2 min | |
| Test baseline | 3 min | |
| Commit changes | 2 min | |
| **TOTAL** | **45 min** | |

---

## Next Steps After Completion

Once XmlNamespace error is fixed:

1. **Verify Baseline** (`AUTOLOAD_WEEK3_SESSION3_STEP2_PROMPT.md`)
   - Run full test suite
   - Confirm 258/258 examples execute
   - Document baseline status

2. **Continue Autoload Conversion** (`AUTOLOAD_WEEK3_SESSION3_STEP3_PROMPT.md`)
   - Convert 90+ wordprocessingml files
   - Update autoload declarations
   - Test after each batch

---

## References

- **Continuation Plan**: `AUTOLOAD_WEEK3_SESSION3_CONTINUATION_PLAN.md`
- **Status Tracker**: `AUTOLOAD_WEEK3_SESSION3_STATUS.md`
- **Namespace File**: `lib/uniword/ooxml/namespaces.rb`
- **Lutaml-Model Source**: `/Users/mulgogi/src/lutaml/lutaml-model`

---

**Ready to Begin**: Yes ✅
**Blocker**: None (namespace consolidation complete)
**Priority**: CRITICAL 🔴 (blocks all progress)