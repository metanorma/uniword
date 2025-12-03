# Documentation Archive Plan - November 29, 2024

## Purpose

Clean up root directory by moving obsolete and completed work documentation to `old-docs/` while keeping only active documentation visible.

## Active Documentation (Keep in Root)

### Current Work (Phase 3)
- `PHASE3_FULL_ROUNDTRIP_PLAN.md` - Master 4-week plan
- `PHASE3_IMPLEMENTATION_STATUS.md` - Status tracker
- `PHASE3_CONTINUATION_PROMPT.md` - Session 2 continuation
- `PHASE3_SESSION3_PROMPT.md` - Session 3 continuation (new)

### Official Documentation
- `README.adoc` - Main documentation
- `CHANGELOG.md` - Version history
- `CONTRIBUTING.md` - Contributor guide
- `LICENSE.txt` - License
- `Gemfile`, `Gemfile.lock` - Dependencies
- `uniword.gemspec` - Gem specification
- `Rakefile` - Build tasks

### Configuration
- `.rubocop.yml`, `.rubocop_todo.yml` - Code style
- `.rspec`, `.rspec_status` - Test configuration
- `.gitignore` - Git configuration
- `.yardopts` - Documentation generation

## Files to Archive

### Phase 1 & 2 Completed Work (18 files)
```
PHASE1_THEME_ROUNDTRIP_COMPLETE.md
PHASE2_COMPLETE_IMPLEMENTATION_STATUS.md
PHASE2_CONTINUATION_PLAN.md
PHASE2_CONTINUATION_PROMPT.md
CONTINUE_ROUNDTRIP_WORK.md
CONTINUE_SESSION_12.md
WEEK1_CONTINUATION_PLAN.md
WEEK1_NEXT_STEPS.md
WEEK1_TYPE_NAMESPACE_COMPLETE.md
```

### Old Version Planning (9 files)
```
V1.1.0_ACHIEVEMENTS.md
V1.1.0_ROADMAP.md
V2.0_CONTINUATION_PLAN.md
V2.0_IMPLEMENTATION_STATUS.md
V2.0_RADICAL_REWRITE_STATUS.md
V2.0.0_FAILURE_ANALYSIS.md
V2.1_COMPLETION_REPORT.md
V3.0_COMPLETION_REPORT.md
V3.0_PLURIMATH_ARCHITECTURE.md
```

### Old Roadmaps & Analysis (5 files)
```
FUTURE_IMPROVEMENTS_ROADMAP.md
PRIORITIZED_FEATURE_ROADMAP.md
ROADMAP_TO_ZERO_FAILURES.md
MILESTONE_2.5_SUMMARY.md
SEQUENCE_2_ANALYSIS.md
```

### Old Implementation Plans (10 files)
```
COMPREHENSIVE_TEST_IMPORT_REPORT.md
DEVELOPMENT_PLAN.md
ELEMENT_VALIDATION_FIX.md
FINAL_20_FAILURES_ANALYSIS.md
FINAL_TEST_ANALYSIS_REPORT.md
FINAL_VALIDATION_REPORT.md
IMPLEMENTATION_STATUS.md
METANORMA_VALIDATION_SUMMARY.md
ROUNDTRIP_COMPLETION_PLAN.md
ROUNDTRIP_IMPLEMENTATION_STATUS.md
```

### Temporary Work Files (8 files)
```
PHASE3_CONTINUATION_PLAN.md (superseded by PHASE3_CONTINUATION_PROMPT.md)
UNIWORD_DEVELOPMENT_PLAN.md (old)
SCHEMA_ORGANIZATION_DESIGN.md (implemented)
PERFORMANCE.md (outdated)
RELEASE_NOTES.md (should merge into CHANGELOG.md)
round-trip-requirement.md (superseded)
```

**Total to Archive**: ~50 files

## Archive Structure

```
old-docs/
├── phase1/
│   └── PHASE1_THEME_ROUNDTRIP_COMPLETE.md
├── phase2/
│   ├── PHASE2_COMPLETE_IMPLEMENTATION_STATUS.md
│   ├── PHASE2_CONTINUATION_PLAN.md
│   ├── PHASE2_CONTINUATION_PROMPT.md
│   ├── WEEK1_*.md
│   └── CONTINUE_*.md
├── versions/
│   ├── V1.1.0_*.md
│   ├── V2.0_*.md
│   ├── V2.1_*.md
│   └── V3.0_*.md
├── planning/
│   ├── *_ROADMAP.md
│   ├── MILESTONE_*.md
│   └── SEQUENCE_*.md
├── implementation/
│   ├── COMPREHENSIVE_TEST_IMPORT_REPORT.md
│   ├── DEVELOPMENT_PLAN.md
│   ├── IMPLEMENTATION_STATUS.md
│   └── *_ANALYSIS.md
└── temporary/
    ├── PHASE3_CONTINUATION_PLAN.md
    ├── SCHEMA_ORGANIZATION_DESIGN.md
    └── round-trip-requirement.md
```

## Documentation Updates Needed

### README.adoc
- [ ] Add section on Property Implementation (14 properties)
- [ ] Update StyleSet documentation (24 sets supported)
- [ ] Update Theme documentation (28 themes bundled)
- [ ] Add examples of new properties (Highlight, VerticalAlign, Position)

### CHANGELOG.md
- [ ] Add v1.1.0 (in development) section
- [ ] Document 3 new properties (Session 2)
- [ ] Document full round-trip for 24 StyleSets
- [ ] Note architecture improvements (Pattern 0)

### docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md
- [x] Already comprehensive and up-to-date
- No changes needed

## Execution Commands

```bash
cd /Users/mulgogi/src/mn/uniword

# Create archive structure
mkdir -p old-docs/{phase1,phase2,versions,planning,implementation,temporary}

# Archive Phase 1 & 2
mv PHASE1_THEME_ROUNDTRIP_COMPLETE.md old-docs/phase1/
mv PHASE2_*.md old-docs/phase2/
mv CONTINUE_*.md old-docs/phase2/
mv WEEK1_*.md old-docs/phase2/

# Archive version planning
mv V*.md old-docs/versions/

# Archive roadmaps
mv *ROADMAP*.md old-docs/planning/
mv MILESTONE_*.md old-docs/planning/
mv SEQUENCE_*.md old-docs/planning/

# Archive implementation docs
mv COMPREHENSIVE_TEST_IMPORT_REPORT.md old-docs/implementation/
mv DEVELOPMENT_PLAN.md old-docs/implementation/
mv IMPLEMENTATION_STATUS.md old-docs/implementation/
mv *ANALYSIS.md old-docs/implementation/
mv *VALIDATION*.md old-docs/implementation/
mv ELEMENT_VALIDATION_FIX.md old-docs/implementation/
mv ROUNDTRIP_*.md old-docs/implementation/

# Archive temporary files
mv PHASE3_CONTINUATION_PLAN.md old-docs/temporary/
mv SCHEMA_ORGANIZATION_DESIGN.md old-docs/temporary/
mv round-trip-requirement.md old-docs/temporary/
mv PERFORMANCE.md old-docs/temporary/
mv UNIWORD_DEVELOPMENT_PLAN.md old-docs/temporary/

# Archive release notes (should merge into CHANGELOG first)
mv RELEASE_NOTES.md old-docs/temporary/
```

## Post-Archive Root Directory

After archiving, root directory will contain:

**Active Work** (4 files):
- PHASE3_FULL_ROUNDTRIP_PLAN.md
- PHASE3_IMPLEMENTATION_STATUS.md
- PHASE3_CONTINUATION_PROMPT.md
- PHASE3_SESSION3_PROMPT.md

**Official Docs** (4 files):
- README.adoc
- CHANGELOG.md
- CONTRIBUTING.md
- LICENSE.txt

**Configuration** (~15 files):
- Build/test/gem config files
- .rubocop, .rspec, etc.

**Temporary Test Artifacts** (keep for now):
- rspec_*.json, rspec_*.log
- test_*.txt, test_*.docx
- *.rb scripts

**Total files in root**: ~35 (down from ~85)

## Benefits

1. **Clarity**: Only current work visible
2. **Focus**: Reduced cognitive load
3. **History**: All old work preserved
4. **Organization**: Clear structure for reference

## Rollback Plan

If needed, all files can be restored:
```bash
cp -r old-docs/phase1/* .
cp -r old-docs/phase2/* .
# etc.
```

## Next Steps After Archive

1. Update README.adoc with Phase 3 progress
2. Update CHANGELOG.md with v1.1.0 development notes
3. Review docs/ directory for outdated content
4. Continue with Session 3 implementation