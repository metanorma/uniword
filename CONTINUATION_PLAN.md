# Uniword: Architecture Cleanup & Autoload Migration - Continuation Plan

**Status**: Anti-Pattern Cleanup Complete ✅ | Full Migration Pending
**Date**: December 4, 2024
**Branch**: feature/autoload-migration

---

## What's Complete ✅

### Phase 1: Main Entry Point Autoload
- Migrated `lib/uniword.rb` (12 → 10 require_relative)
- Added 58 top-level class autoloads
- Documentation updated (README, CHANGELOG, CONTRIBUTING)
- Commit: `f7f0edd`, `d4ee4d2`

### Phase 2: Anti-Pattern Cleanup
- Deleted 3 manual parser files
- Removed 37 require_relative calls (416 → 379)
- Restored MODEL-DRIVEN architecture compliance
- Commit: `4fa779d`

---

## What's Remaining 🔴

### Priority 1: Implement StylesetPackage (MODEL-DRIVEN)
**Status**: Not started
**Estimated**: 4-6 hours
**Blocking**: StyleSet.from_dotx() functionality

Create proper lutaml-model package following DocxPackage pattern:

```ruby
# lib/uniword/stylesets/package.rb
module Uniword
  module Stylesets
    class Package < Lutaml::Model::Serializable
      # word/styles.xml
      attribute :styles_configuration, StylesConfiguration
      
      def self.from_file(path)
        # Extract ZIP
        # Deserialize styles.xml using lutaml-model
        # Return Package instance
      end
      
      def styleset
        # Convert StylesConfiguration to StyleSet
        StyleSet.new(
          name: extract_name,
          styles: styles_configuration.styles
        )
      end
    end
  end
end
```

Then restore `StyleSet.from_dotx()`:
```ruby
def self.from_dotx(path)
  Stylesets::Package.from_file(path).styleset
end
```

### Priority 2: Full Autoload Migration (379 require_relative)
**Status**: Planned, not started
**Estimated**: 3 weeks (40 hours compressed)

**Week 1: Namespace Modules (~150 require_relative)**
- Wordprocessingml (~50)
- WpDrawing, DrawingML (~40)
- VML, Math, SharedTypes, others (~60)

**Week 2: Property Files (~100 require_relative)**
- RunProperties (16)
- ParagraphProperties (10)
- TableProperties, SDT properties (~74)

**Week 3: Feature Files (~129 require_relative)**
- Theme infrastructure
- CLI
- Validators, transformers, etc.

**Target Final State**: 379 → 45 require_relative (88% reduction)

### Priority 3: Similar Anti-Patterns
**Status**: Not analyzed
**Estimated**: TBD

Check for similar manual parsers in:
- `lib/uniword/theme/` - Theme loading
- Other infrastructure files

---

## Architecture Principles (MUST FOLLOW)

### 1. MODEL-DRIVEN Architecture
- ✅ Every XML file = lutaml-model class
- ✅ No manual XML parsing
- ✅ Use `.from_xml()` / `.to_xml()`
- ❌ NO manual Nokogiri parsing

### 2. Package Pattern
```
Package (lutaml-model)
├── Part1 (lutaml-model)
├── Part2 (lutaml-model)
└── extract() / package() methods
```

Example: DocxPackage, ThemePackage, StylesetPackage

### 3. Autoload Strategy
- **Default**: Use autoload
- **Exception**: Only if architecturally necessary
  - Parent class loading
  - Circular dependencies  
  - Module-level constants
  - Self-registration side effects

### 4. MECE (Mutually Exclusive, Collectively Exhaustive)
- One responsibility per class
- No overlap
- Complete coverage

---

## Testing Strategy

### Baseline Tests (MUST PASS)
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
# Expected: 258/258 passing
```

### After Each Change
1. Run baseline tests
2. Verify autoload works
3. Check for regressions
4. Update documentation

---

## Timeline

### Immediate (Next Session)
1. Implement StylesetPackage (4-6 hours)
2. Test .dotx loading
3. Restore full StyleSet functionality

### Short Term (2-4 weeks)
1. Full autoload migration (40 hours)
2. Achieve 88% reduction
3. Document all exceptions

### Long Term
1. Monitor performance improvements
2. Maintain architecture compliance
3. Guide future contributors

---

## Success Criteria

- ✅ MODEL-DRIVEN architecture (100% compliance)
- ✅ Zero manual XML parsers
- ✅ StyleSet.from_dotx() working
- ✅ All 258 baseline tests passing
- ✅ 379 → 45 require_relative (target)
- ✅ Clear documentation

---

## Reference Documents

All planning documents archived in `old-docs/autoload-migration/`:
- AUTOLOAD_CLEANUP_PLAN.md
- AUTOLOAD_FULL_MIGRATION_PLAN.md
- AUTOLOAD_FULL_MIGRATION_STATUS.md
- AUTOLOAD_FULL_MIGRATION_PROMPT.md
- AUTOLOAD_MIGRATION_COMPLETE_SUMMARY.md
- Plus 11 other session documents

---

## Commands Reference

```bash
# Check require_relative count
grep -r "require_relative" lib/ --include="*.rb" | wc -l

# Run tests
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb

# Check git status
git status

# View commits
git log --oneline -10
```

---

**Created**: December 4, 2024
**Status**: Ready for next phase
**Next Action**: Implement StylesetPackage (Priority 1)