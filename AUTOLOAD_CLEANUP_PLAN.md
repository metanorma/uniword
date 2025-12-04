# Uniword: Autoload Migration - Cleanup Plan

**Issue**: We have 416 require_relative calls, but more critically, we have ANTI-PATTERNS that violate model-driven architecture.

---

## Critical Issues Found

### 1. Manual XML Parsers (ANTI-PATTERN) 🚨

We have manual XML parsers that should use lutaml-model instead:

| File | Lines | Problem | Solution |
|------|-------|---------|----------|
| styleset_xml_parser.rb | 32 require_relative | Manual XML parsing | Use StylesConfiguration.from_xml() |
| theme_xml_parser.rb | ? | Manual XML parsing | Use Theme.from_xml() |
| Similar parsers | ? | Manual XML parsing | Use lutaml-model |

**Why this is critical**: 
- Violates MODEL-DRIVEN architecture
- Duplicates lutaml-model functionality
- 32 require_relative in one file alone
- Hard to maintain

### 2. Excessive require_relative (SYMPTOM)

Total: 416 require_relative calls across codebase

---

## Phase 1: Delete Manual Parsers (PRIORITY 1)

### Step 1: Verify StylesConfiguration Can Deserialize

Check if StylesConfiguration has proper XML mapping:

```ruby
# lib/uniword/styles_configuration.rb should have:
xml do
  element 'styles'
  namespace Ooxml::Namespaces::WordProcessingML
  map_element 'style', to: :styles  # This might be commented out
end
```

If map_element is disabled, we need to:
1. Ensure Style class exists in lutaml-model format
2. Enable the mapping
3. Test deserialization

### Step 2: Refactor StylesetLoader

**Current (WRONG)**:
```ruby
# lib/uniword/stylesets/styleset_loader.rb
parser = StyleSetXmlParser.new  # Manual parser - BAD!
styles = parser.parse(extracted[:styles])
```

**Target (CORRECT)**:
```ruby
# lib/uniword/stylesets/styleset_loader.rb
styles_config = Uniword::StylesConfiguration.from_xml(extracted[:styles])
styles = styles_config.styles  # Get Style objects from lutaml-model
```

### Step 3: Delete Manual Parser

```bash
# Delete the anti-pattern file
rm lib/uniword/stylesets/styleset_xml_parser.rb

# Remove autoload
# Edit lib/uniword.rb, remove:
autoload :StylesetXmlParser, 'uniword/stylesets/styleset_xml_parser'
```

**Impact**: Removes 32 require_relative calls immediately!

### Step 4: Test Round-Trip

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
# Expected: 84/84 passing
```

---

## Phase 2: Similar Manual Parsers

### Files to Check and Potentially Delete

```bash
# Find all *_parser.rb or *_xml_*.rb files
find lib/ -name "*parser*.rb" -o -name "*xml*.rb" | grep -v spec
```

Likely candidates:
- `lib/uniword/theme/theme_xml_parser.rb`
- Any other manual XML parsers

For each:
1. Check if corresponding lutaml-model class exists (Theme, etc.)
2. Verify lutaml-model class can deserialize
3. Refactor callers to use lutaml-model
4. Delete manual parser

---

## Phase 3: Autoload Remaining (After Cleanup)

After deleting manual parsers, re-count require_relative:

```bash
grep -r "require_relative" lib/ --include="*.rb" | wc -l
# Expected: <384 (down from 416 after parser deletion)
```

Then proceed with systematic autoload migration per the original plan.

---

## Expected Results

### After Phase 1 (Manual Parser Cleanup)
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Manual parsers | 2-3 | 0 | -100% |
| styleset_xml_parser.rb require_relative | 32 | 0 | -32 |
| Total require_relative | 416 | ~384 | -32 (-8%) |
| Architecture compliance | ❌ VIOLATED | ✅ COMPLIANT | Fixed |

### After Phase 2 (Similar Parser Cleanup)
| Metric | After Phase 1 | After Phase 2 | Change |
|--------|---------------|---------------|--------|
| Total require_relative | ~384 | ~320 | -64 (-17%) |

### After Phase 3 (Full Autoload Migration)
| Metric | After Phase 2 | Final | Change |
|--------|---------------|-------|--------|
| Total require_relative | ~320 | ~45 | -275 (-86%) |

---

## Success Criteria

- ✅ Zero manual XML parsers (100% lutaml-model)
- ✅ All 258 baseline tests passing
- ✅ MODEL-DRIVEN architecture restored
- ✅ Significant require_relative reduction as bonus

---

## Next Actions

1. **Phase 1, Step 1**: Verify StylesConfiguration XML mapping
2. **Phase 1, Step 2**: Refactor StylesetLoader
3. **Phase 1, Step 3**: Delete styleset_xml_parser.rb
4. **Phase 1, Step 4**: Test round-trip

---

**Created**: December 4, 2024
**Status**: Ready to execute Phase 1
**Priority**: CRITICAL - Architectural violation fix