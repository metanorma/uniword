# Autoload Week 3 Session 3: Continuation Plan

**Created**: December 8, 2024
**Status**: Namespace Consolidation COMPLETE ✅ | Ready for Wordprocessingml Conversion
**Blocker Resolved**: Namespace conflict fixed (commit 66d971c)

---

## Phase Status Overview

### ✅ COMPLETE: Namespace Consolidation (45 minutes)

**Problem Solved**: Two conflicting WordProcessingML namespaces
- `Uniword::Wordprocessingml` (90+ elements)
- `Uniword::Ooxml::WordProcessingML` (3 properties) ← REMOVED

**Solution**: Consolidated into single `Uniword::Wordprocessingml` namespace

**Files Changed**: 27
- Moved: 3 properties files
- Updated: 18+ references across codebase
- Deleted: 1 duplicate module file + empty directory

**Commit**: `66d971c` - refactor(namespace): consolidate WordProcessingML into single namespace

---

## Current Blocker: Pre-Existing Error

**Error**: `Lutaml::Model::XmlNamespace` not found in `lib/uniword/ooxml/namespaces.rb`

**Status**: **UNRELATED** to namespace consolidation work (pre-existing)

**Impact**: Prevents library from loading

**Priority**: **CRITICAL** - Must fix before continuing

---

## Next Steps (Compressed Timeline)

### Step 1: Fix XmlNamespace Error (30-45 min) 🔴 URGENT

**Goal**: Resolve `Lutaml::Model::XmlNamespace` not found error

**Investigation**:
1. Check if `XmlNamespace` class exists in lutaml-model gem
2. Verify correct lutaml-model version requirement
3. Check if API changed in recent lutaml-model versions
4. May need to update namespace implementation

**Files to Check**:
- `lib/uniword/ooxml/namespaces.rb` (error location)
- `Gemfile` (lutaml-model version)
- Local lutaml-model source if path dependency

**Expected Fix**: Either update lutaml-model version or refactor namespace declarations

### Step 2: Verify Baseline Tests (15 min)

**Goal**: Confirm 258/258 baseline tests passing after XmlNamespace fix

**Command**:
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                 spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, 177 failures (known baseline)

### Step 3: Complete Wordprocessingml Autoload Conversion (2-3 hours)

**Goal**: Convert remaining 90+ wordprocessingml element files to use autoload

**Current State**:
- Namespace conflict: ✅ RESOLVED
- Properties files: ✅ MOVED and UPDATED
- Element files: ⏳ Ready for autoload conversion

**Files to Convert** (~90 files in `lib/uniword/wordprocessingml/`):
- Core: document_root.rb, body.rb, paragraph.rb, run.rb, table.rb, etc.
- Elements: hyperlink.rb, bookmark_start.rb, field_char.rb, etc.
- Properties: section_properties.rb, table_cell_properties.rb, etc.
- Structure: level.rb, style.rb, structured_document_tag.rb, etc.

**Conversion Pattern** (per file):
1. Remove manual `require_relative` for wordprocessingml classes
2. Add autoload declaration to `lib/uniword/wordprocessingml.rb`
3. Verify class references use simple names (already in module)

**Estimated Time**: ~2 min/file × 90 files = 3 hours (compress to 2 hours with batch operations)

### Step 4: Update lib/uniword.rb (30 min)

**Goal**: Remove wordprocessingml eager loading, rely on autoload

**Changes**:
1. Remove `require_relative 'uniword/wordprocessingml'` if safe
2. Keep namespace module loading if needed for constants
3. Update aliases to use autoloaded classes

**Verification**: Ensure document creation still works

### Step 5: Test Suite Verification (30 min)

**Goal**: Verify no regressions from autoload conversion

**Tests**:
1. Baseline: 258/258 (StyleSet + Theme)
2. Unit tests: All wordprocessingml classes load correctly
3. Integration: Document creation/loading works

**Expected**: All tests maintain baseline (258 passing, known failures unchanged)

### Step 6: Documentation Updates (30 min)

**Goal**: Document namespace consolidation and autoload migration

**Files to Create/Update**:
1. `AUTOLOAD_WEEK3_SESSION3_COMPLETE.md` - Session summary
2. `docs/NAMESPACE_MIGRATION_GUIDE.md` - Add namespace consolidation section
3. `CHANGELOG.md` - Add breaking change notice

**Files to Archive**:
- Move to `old-docs/`:
  - `AUTOLOAD_WEEK3_SESSION3_NAMESPACE_FIX_PLAN.md` (completed)
  - `AUTOLOAD_WEEK3_SESSION3_NAMESPACE_FIX_PROMPT.md` (completed)
  - Other temporary Session 3 docs

---

## Compressed Timeline Summary

| Step | Task | Estimated Time | Priority |
|------|------|---------------|----------|
| 1 | Fix XmlNamespace Error | 30-45 min | 🔴 CRITICAL |
| 2 | Verify Baseline Tests | 15 min | 🔴 CRITICAL |
| 3 | Wordprocessingml Autoload | 2-3 hours | 🟡 HIGH |
| 4 | Update lib/uniword.rb | 30 min | 🟡 HIGH |
| 5 | Test Suite Verification | 30 min | 🟢 MEDIUM |
| 6 | Documentation | 30 min | 🟢 MEDIUM |
| **TOTAL** | **Week 3 Session 3** | **4.5-5.5 hours** | |

---

## Success Criteria

### Week 3 Session 3 COMPLETE When:

1. ✅ XmlNamespace error resolved
2. ✅ Baseline tests passing (258/258)
3. ✅ All wordprocessingml files use autoload
4. ✅ No manual requires in wordprocessingml files
5. ✅ Autoload declarations in wordprocessingml.rb
6. ✅ lib/uniword.rb uses autoloaded classes
7. ✅ Zero test regressions
8. ✅ Documentation updated

---

## Breaking Changes Notice

### Namespace Consolidation (commit 66d971c)

**REMOVED**:
```ruby
Uniword::Ooxml::WordProcessingML::ParagraphProperties
Uniword::Ooxml::WordProcessingML::RunProperties
Uniword::Ooxml::WordProcessingML::TableProperties
```

**USE INSTEAD**:
```ruby
Uniword::Wordprocessingml::ParagraphProperties
Uniword::Wordprocessingml::RunProperties
Uniword::Wordprocessingml::TableProperties
```

**Impact**: Any code directly referencing `Ooxml::WordProcessingML` namespace must update

**Migration**: Simple find-replace: `Ooxml::WordProcessingML::` → `Wordprocessingml::`

---

## Risk Mitigation

### Pre-Existing Errors

**Risk**: XmlNamespace error may indicate lutaml-model version incompatibility

**Mitigation**:
1. Test with latest stable lutaml-model
2. Test with local path dependency
3. Check lutaml-model changelog for breaking changes
4. May need to refactor namespace implementation

### Autoload Circular Dependencies

**Risk**: Autoload may expose hidden circular dependencies

**Mitigation**:
1. Convert files in dependency order (leaves first)
2. Test after each batch conversion
3. Use explicit requires for known cycles
4. Document any required eager loading

### Performance Impact

**Risk**: Autoload may slow down initial class loading

**Mitigation**:
1. Measure load times before/after
2. Acceptable: < 2x slowdown
3. Keep critical path eager loaded if needed

---

## Next Session Prompt

See: `AUTOLOAD_WEEK3_SESSION3_STEP1_PROMPT.md`

**Focus**: Fix XmlNamespace error and verify baseline tests

**Estimated Time**: 45-60 minutes

**Deliverables**:
1. XmlNamespace error resolved
2. Baseline tests passing (258/258)
3. Root cause documented
4. Ready for autoload conversion