# Uniword: Complete Autoload Migration Plan

**Current State**: Only `lib/uniword.rb` migrated (12 require_relative → 10)
**Remaining**: 404 require_relative calls across 100+ files
**Goal**: Migrate ALL feasible require_relative to autoload

---

## Current State Analysis

```
Total require_relative calls: 416
├── lib/uniword.rb: 12 (10 remain - documented exceptions)
├── Module files: ~150 (namespace modules loading internal classes)
├── Property files: ~100 (properties loading nested classes)
├── Feature files: ~154 (individual files loading dependencies)
```

### Top Offenders
| File | Count | Type |
|------|-------|------|
| stylesets/styleset_xml_parser.rb | 32 | Properties |
| ooxml/wordprocessingml/run_properties.rb | 16 | Properties |
| structured_document_tag_properties.rb | 13 | Properties |
| theme.rb | 11 | Model |
| cli.rb | 11 | Infrastructure |
| ooxml/wordprocessingml/paragraph_properties.rb | 10 | Properties |

---

## Migration Strategy

### Phase 1: Namespace Module Files (Priority 1)
**Target**: ~150 require_relative in 22 namespace files

Convert internal class loading to autoload in:
- `lib/uniword/wordprocessingml.rb`
- `lib/uniword/wp_drawing.rb`
- `lib/uniword/drawingml.rb`
- `lib/uniword/vml.rb`
- `lib/uniword/math.rb`
- `lib/uniword/shared_types.rb`
- Plus 16 other namespace modules

**Example** (wordprocessingml.rb currently has ~0, should have ~50 autoloads):
```ruby
module Uniword
  module Wordprocessingml
    # Instead of require_relative
    autoload :Paragraph, 'uniword/wordprocessingml/paragraph'
    autoload :Run, 'uniword/wordprocessingml/run'
    # ... etc for ~50 classes
  end
end
```

### Phase 2: Property Files (Priority 2)
**Target**: ~100 require_relative in property files

Convert nested property loading:
- `lib/uniword/ooxml/wordprocessingml/run_properties.rb` (16)
- `lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb` (10)
- `lib/uniword/ooxml/wordprocessingml/table_properties.rb` (4)
- `lib/uniword/structured_document_tag_properties.rb` (13)

**Example** (run_properties.rb):
```ruby
module Uniword
  module Ooxml
    module WordProcessingML
      class RunProperties
        # Instead of require_relative for each property
        autoload :Bold, 'uniword/properties/bold'
        autoload :Italic, 'uniword/properties/italic'
        # ... etc
      end
    end
  end
end
```

### Phase 3: Feature Files (Priority 3)
**Target**: ~154 require_relative in feature files

Convert feature dependencies:
- `lib/uniword/stylesets/styleset_xml_parser.rb` (32)
- `lib/uniword/theme.rb` (11)
- `lib/uniword/cli.rb` (11)
- Others

---

## Implementation Plan

### Week 1: Namespace Modules (20 hours)

**Day 1-2**: Wordprocessingml module (50+ classes)
- Analyze all classes in wordprocessingml/
- Create autoload statements
- Test round-trip preservation
- Target: 50 require_relative → autoload

**Day 3**: Drawing modules (wp_drawing, drawingml)
- WpDrawing: ~15 classes
- DrawingML: ~25 classes
- Target: 40 require_relative → autoload

**Day 4**: Other namespace modules
- VML, Math, SharedTypes
- Plus 16 specialty namespaces
- Target: 60 require_relative → autoload

**Day 5**: Testing & validation
- Run full test suite
- Verify autoload functionality
- Fix any regressions

**Outcome**: ~150 require_relative → autoload

### Week 2: Property Files (8 hours)

**Day 1**: Run and Paragraph properties
- run_properties.rb (16 → autoload)
- paragraph_properties.rb (10 → autoload)
- Target: 26 require_relative → autoload

**Day 2**: Table and SDT properties
- table_properties.rb (4 → autoload)
- structured_document_tag_properties.rb (13 → autoload)
- Target: 17 require_relative → autoload

**Day 3**: Remaining property files
- All other property containers
- Target: 57 require_relative → autoload

**Day 4**: Testing & validation

**Outcome**: ~100 require_relative → autoload

### Week 3: Feature Files (12 hours)

**Day 1-2**: Large feature files
- styleset_xml_parser.rb (32 → autoload)
- theme.rb (11 → autoload)
- cli.rb (11 → autoload)

**Day 3-4**: Medium feature files
- Document validators, transformers, etc.
- Target: 100 require_relative → autoload

**Day 5**: Testing & validation

**Outcome**: ~154 require_relative → autoload

---

## Expected Results

### Final State
| Stage | Before | After | Improvement |
|-------|--------|-------|-------------|
| Main entry | 12 | 10 | -2 |
| Namespace modules | ~150 | ~10 | -140 |
| Property files | ~100 | ~5 | -95 |
| Feature files | ~154 | ~20 | -134 |
| **Total** | **416** | **~45** | **-371 (-89%)** |

### Remaining require_relative (~45)
1. **Base requirements** (2): version, ooxml/namespaces
2. **Namespace cross-deps** (6): Core namespace modules
3. **Format handlers** (2): docx_handler, mhtml_handler
4. **Parent class loading** (~20): Classes that must load parent first
5. **Circular dependencies** (~15): Small set of unavoidable cycles

---

## Architectural Considerations

### When require_relative is Required

1. **Parent Class Loading**
   ```ruby
   # Child MUST load parent first
   require_relative 'base_element'
   class Paragraph < BaseElement
   ```

2. **Circular Dependencies**
   ```ruby
   # Document → Body → Paragraph → Run
   # Run needs Document constants
   require_relative '../document'  # Must use require_relative
   ```

3. **Namespace Initialization**
   ```ruby
   # Namespace module must be loaded before classes
   require_relative 'wordprocessingml'  # Then autoload classes inside
   ```

### Testing Strategy

After each phase:
1. Run full test suite (342+ tests)
2. Verify autoload triggers correctly
3. Check no circular dependency errors
4. Validate memory usage improvements
5. Measure startup time improvements

---

## Success Criteria

- ✅ 89% reduction in require_relative calls (416 → 45)
- ✅ All 342+ baseline tests passing
- ✅ Zero regressions in functionality
- ✅ Documented exceptions for remaining require_relative
- ✅ Updated documentation reflecting full migration
- ✅ Faster startup time (lazy loading)
- ✅ Lower memory footprint

---

## Timeline

- **Week 1**: Namespace modules (20 hours)
- **Week 2**: Property files (8 hours)
- **Week 3**: Feature files (12 hours)
- **Total**: 40 hours (compressed from 60 hours)

---

## Next Steps

1. Review and approve this plan
2. Begin Week 1, Day 1: Wordprocessingml module migration
3. Use systematic approach: analyze → migrate → test → document
4. Track progress in AUTOLOAD_FULL_MIGRATION_STATUS.md

---

**Created**: December 4, 2024
**Status**: Ready to begin
**Estimated Completion**: 3 weeks (compressed timeline)