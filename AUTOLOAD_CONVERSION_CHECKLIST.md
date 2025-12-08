# Autoload Migration: Conversion Checklist

**Status**: Week 3 Session 2 - Audit Complete
**Date**: December 8, 2024
**Total Files with require_relative**: 160 files

---

## Audit Summary

### Files Remaining by Category

| Directory | Count | Priority | Phase |
|-----------|-------|----------|-------|
| properties/ | 29 | High | Phase 2 |
| lib/uniword (root) | 28 | Low | Phase 3 |
| wordprocessingml/ | 10 | High | Phase 2 |
| ooxml/ | 9 | Low | Phase 3 |
| ooxml/types/ | 8 | Low | Phase 3 |
| validation/validators/ | 7 | Low | Phase 4 |
| styles/ | 7 | Medium | Phase 3 |
| transformation/ | 6 | Low | Phase 4 |
| quality/rules/ | 6 | Low | Phase 4 |
| batch/stages/ | 6 | Low | Phase 4 |
| validation/ | 5 | Low | Phase 4 |
| metadata/ | 5 | Low | Phase 4 |
| validation/checkers/ | 4 | Low | Phase 4 |
| theme/ | 4 | Medium | Phase 3 |
| template/ | 4 | Low | Phase 4 |
| ooxml/wordprocessingml/ | 3 | Medium | Phase 3 |
| ooxml/schema/ | 3 | Low | Phase 4 |
| assembly/ | 3 | Low | Phase 4 |
| warnings/ | 2 | Low | Phase 4 |
| themes/ | 2 | Medium | Phase 3 |
| stylesets/ | 2 | Medium | Phase 3 |
| Others (single files) | 7 | Low | Phase 4 |
| **Total** | **160** | | |

---

## Phase 2: Element Files (High Priority) - NEXT

### Wordprocessingml Elements (10 files)

**Target**: Convert to module autoloads
**Pattern**: Create `lib/uniword/wordprocessingml.rb` with autoload index
**Time**: 2-3 hours

- [ ] lib/uniword/wordprocessingml/table.rb
- [ ] lib/uniword/wordprocessingml/paragraph.rb
- [ ] lib/uniword/wordprocessingml/run.rb
- [ ] lib/uniword/wordprocessingml/level.rb
- [ ] lib/uniword/wordprocessingml/table_cell_properties.rb
- [ ] lib/uniword/wordprocessingml/r_pr_default.rb
- [ ] lib/uniword/wordprocessingml/p_pr_default.rb
- [ ] lib/uniword/wordprocessingml/document_root.rb
- [ ] lib/uniword/wordprocessingml/style.rb
- [ ] lib/uniword/wordprocessingml/structured_document_tag.rb

**Module File**: Create `lib/uniword/wordprocessingml.rb`:
```ruby
# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    autoload :Table, 'uniword/wordprocessingml/table'
    autoload :Paragraph, 'uniword/wordprocessingml/paragraph'
    autoload :Run, 'uniword/wordprocessingml/run'
    autoload :Level, 'uniword/wordprocessingml/level'
    autoload :TableCellProperties, 'uniword/wordprocessingml/table_cell_properties'
    autoload :RPrDefault, 'uniword/wordprocessingml/r_pr_default'
    autoload :PPrDefault, 'uniword/wordprocessingml/p_pr_default'
    autoload :DocumentRoot, 'uniword/wordprocessingml/document_root'
    autoload :Style, 'uniword/wordprocessingml/style'
    autoload :StructuredDocumentTag, 'uniword/wordprocessingml/structured_document_tag'
  end
end
```

### Properties (29 files) - AFTER WORDPROCESSINGML

**Status**: Large directory, assess if module needed
**Decision Point**: Check if properties already have module autoloads

---

## Phase 3: Supporting Modules (Medium Priority)

### Styles (7 files)
- Assess structure
- Determine if module autoload needed

### Theme/Themes (6 files total)
- theme/ (4 files)
- themes/ (2 files)
- Consolidate or separate?

### StyleSets (2 files)
- Already using Package pattern
- Verify no further changes needed

### OOXML Wordprocessingml (3 files)
- lib/uniword/ooxml/wordprocessingml/
- Coordinate with main wordprocessingml/

---

## Phase 4: Feature Directories (Low Priority)

### Validation (16 files total)
- validation/ (5 files)
- validation/validators/ (7 files)
- validation/checkers/ (4 files)

### Quality (7 files)
- quality/ (1 file)
- quality/rules/ (6 files)

### Transformation (6 files)
- lib/uniword/transformation/

### Batch (7 files)
- batch/ (1 file)
- batch/stages/ (6 files)

### Assembly (3 files)
- lib/uniword/assembly/

### Metadata (5 files)
- lib/uniword/metadata/

### Template (4 files)
- lib/uniword/template/

### Warnings (2 files)
- lib/uniword/warnings/

### Schema (4 files)
- schema/ (1 file)
- ooxml/schema/ (3 files)

---

## Special Cases

### lib/uniword Root (28 files)

**Note**: These likely include:
- Main module file (`lib/uniword.rb`) - KEEP require statements
- Package classes (already converted)
- Core classes that may have circular dependencies

**Action**: Audit individually, some may be legitimate require_relative for:
- Namespace requires in `lib/uniword.rb`
- Circular dependency handling

### OOXML Core (9 files)
- lib/uniword/ooxml/ (9 files)
- Core infrastructure, assess carefully

### OOXML Types (8 files)
- lib/uniword/ooxml/types/
- Type system, likely needs module

---

## Circular Dependency Tracking

**Instructions**: When converting files, document any true circular dependencies:

```ruby
# In file_a.rb
require_relative 'file_b'  # require_relative kept: circular dependency with file_b

# Explanation: FileA needs FileB in method_x, FileB needs FileA in method_y
# Cannot use autoload due to immediate constant resolution needed
```

**Circular Dependencies Found**:
- (To be documented during conversion)

---

## Conversion Strategy

### Per-File Pattern

1. **Check current requires**:
   ```bash
   grep "require_relative" lib/uniword/wordprocessingml/table.rb
   ```

2. **Identify what it requires**:
   - Properties classes?
   - Other wordprocessingml classes?
   - External dependencies?

3. **Move to autoload**:
   - Add autoload to module file
   - Remove require_relative from class file
   - Test

4. **Mark circular deps**:
   - If can't remove require_relative, document why
   - Add comment: `# require_relative kept: circular dependency`

### Testing After Each File

```bash
# Run baseline tests
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 spec/uniword/theme_roundtrip_spec.rb \
                 --format progress

# Expected: 258 examples, 177 failures (baseline)
```

---

## Success Metrics

| Metric | Start | Target | Phase |
|--------|-------|--------|-------|
| Total require_relative | 160 | ~20-30 | All phases |
| Wordprocessingml | 10 | 0-2 | Phase 2 |
| Properties | 29 | 0-5 | Phase 2-3 |
| Feature dirs | ~50 | 0-10 | Phase 4 |
| Circular deps | Unknown | Document | Ongoing |

---

## Dead Code Check

**Process**:
```bash
# For each file, check if class is referenced
for file in lib/uniword/**/*.rb; do
  class_name=$(basename "$file" .rb | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/')
  if ! grep -r "$class_name" lib/ spec/ --include="*.rb" -q; then
    echo "Possibly unused: $file ($class_name)"
  fi
done
```

**Dead Code Found**:
- (To be documented)

---

## Phase 2 Session 3 Plan

**Goal**: Convert all 10 Wordprocessingml element files to autoload
**Time**: 2-3 hours
**Deliverables**:
1. Created `lib/uniword/wordprocessingml.rb` module file
2. Converted 10 files to use autoload
3. All tests passing (258/258 baseline maintained)
4. Documented any circular dependencies

**Next Session**: `AUTOLOAD_WEEK3_SESSION3_PROMPT.md`

---

**Created**: December 8, 2024
**Updated**: December 8, 2024
**Status**: Audit Complete - Ready for Phase 2