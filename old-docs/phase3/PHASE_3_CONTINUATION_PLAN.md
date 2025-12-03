# Phase 3 v2.0 Integration - Continuation Plan

## Current Status (November 28, 2024)

**Phase 3 Progress**: 90% Complete
- ✅ Core v2.0 integration functional (28/28 integration tests passing)
- ✅ Generated classes as primary API
- ✅ Extension modules working
- ✅ Round-trip with real DOCX files (6/10 tests passing)
- ⚠️ Minor infrastructure issues (4 failing tests)

## Remaining Work to v2.0.0 Release

### Priority 1: Fix Infrastructure (2-3 hours)

#### Task A: Fix [Content_Types].xml Generation
**Issue**: `add_required_files()` in DocxHandler not properly generating [Content_Types].xml

**File**: `lib/uniword/formats/docx_handler.rb`

**Fix Required**:
```ruby
def add_required_files(zip_content)
  # Current implementation calls ContentTypes.new but may not generate proper XML
  # Need to ensure proper OOXML structure
  
  require_relative '../ooxml/content_types'
  require_relative '../ooxml/relationships'
  
  # Add [Content_Types].xml
  unless zip_content['[Content_Types].xml']
    content_types = Ooxml::ContentTypes.new
    # Add proper content type entries
    content_types.add_default('xml', 'application/xml')
    content_types.add_default('rels', 'application/vnd.openxmlformats-package.relationships+xml')
    content_types.add_override('/word/document.xml', 
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml')
    content_types.add_override('/docProps/core.xml',
      'application/vnd.openxmlformats-package.core-properties+xml')
    content_types.add_override('/docProps/app.xml',
      'application/vnd.openxmlformats-officedocument.extended-properties+xml')
    
    zip_content['[Content_Types].xml'] = content_types.to_xml
  end
  
  # Similar fixes for _rels/.rels and word/_rels/document.xml.rels
end
```

**Test**: Run `bundle exec rspec spec/uniword/docx_roundtrip_spec.rb` - should get 10/10 passing

#### Task B: Verify ContentTypes and Relationships Classes
**Files**: 
- `lib/uniword/ooxml/content_types.rb`
- `lib/uniword/ooxml/relationships.rb`

**Check**:
1. Do these classes have proper lutaml-model XML serialization?
2. Do they have methods like `add_default()`, `add_override()`, `add_relationship()`?
3. If not, implement them

**Expected**: These should be simple lutaml-model classes with collections

### Priority 2: Rebuild Style System (Deferred to v2.1)

**Current State**: v1.x style classes archived, StylesConfiguration simplified

**Future Work** (Post v2.0.0):
1. Define Style classes using generated schema
2. Update StylesConfiguration to use Generated::Wordprocessingml::Style
3. Implement ParagraphStyle, CharacterStyle, TableStyle using generated classes
4. Re-enable default style generation

**Timeline**: v2.1 (2-3 weeks after v2.0 release)

### Priority 3: Documentation Updates (1-2 hours)

#### Update README.adoc
**Section to Add**:
- v2.0 Architecture overview
- Generated classes explanation
- Extension methods documentation
- Migration guide from v1.x

#### Create New Docs
- `docs/V2_ARCHITECTURE.md` - Detailed v2.0 architecture
- `docs/GENERATED_CLASSES.md` - How generated classes work
- `docs/MIGRATION_V1_TO_V2.md` - Migration guide

#### Archive Old Docs
Move to `old-docs/`:
- Phase 1, 2, 3 implementation docs
- Session summaries
- Test results
- Temporary status trackers

### Priority 4: Final Testing (1 hour)

**Run All Tests**:
```bash
# Core integration
bundle exec rspec spec/uniword/v2_integration_spec.rb

# Round-trip
bundle exec rspec spec/uniword/docx_roundtrip_spec.rb

# Legacy tests (if any still work)
bundle exec rspec spec/uniword/document_spec.rb
```

**Expected**:
- v2 integration: 28/28 passing ✅
- Round-trip: 10/10 passing (after fix)
- Legacy tests: May fail (expected, they use v1.x style)

### Priority 5: Version Bump & Release (30 min)

1. Update `lib/uniword/version.rb`: `2.0.0`
2. Update `CHANGELOG.md` with v2.0 changes
3. Tag release: `git tag v2.0.0`
4. Push to RubyGems: `gem build && gem push`

## Post-v2.0 Roadmap

### v2.0.1 (Bug fixes)
- Fix any reported issues
- Improve error messages
- Add more examples

### v2.1.0 (Style System)
- Rebuild style system with generated classes
- Re-enable default styles
- StyleSet full support

### v2.2.0 (HTML Import)
- Update HtmlImporter to use generated classes
- Re-enable `Uniword.from_html()`
- Re-enable MHTML format handler

### v2.3.0 (Enhanced Properties)
- Complete property coverage (colors, fonts, etc.)
- Table styling
- Image positioning
- Headers/footers

### v3.0.0 (Future)
- Math equations (OMML)
- Track changes
- Comments
- Advanced table features

## Known Issues & Workarounds

### Issue 1: [Content_Types].xml Missing
**Impact**: Saved DOCX may not open in older Word versions
**Workaround**: Fix in Priority 1 Task A
**Severity**: Medium

### Issue 2: Style System Simplified
**Impact**: Cannot create custom styles, no default styles
**Workaround**: Use direct property assignment
**Severity**: Low (most users don't need styles)
**Fix**: v2.1

### Issue 3: HTML Import Disabled
**Impact**: Cannot convert HTML to DOCX
**Workaround**: Use v1.x or wait for v2.2
**Severity**: Low (niche feature)
**Fix**: v2.2

### Issue 4: MHTML Format Limited
**Impact**: MHTML format doesn't import HTML
**Workaround**: Use DOCX format only
**Severity**: Very Low
**Fix**: v2.2

## Success Criteria for v2.0.0 Release

### Must Have (Blocking)
- [x] Core API functional (Document, Paragraph, Run)
- [x] Extension methods working
- [x] Serialization/deserialization working
- [x] Save/load DOCX files
- [x] Round-trip preserves content
- [ ] [Content_Types].xml generation (Priority 1)
- [ ] README.adoc updated with v2.0 info
- [x] 28/28 integration tests passing

### Should Have (Important but not blocking)
- [ ] 10/10 round-trip tests passing
- [ ] Migration guide
- [ ] v2.0 architecture docs
- [ ] Examples updated

### Nice to Have (Can defer)
- StyleSet support
- Theme support  
- HTML import
- Complete property coverage

## Estimated Timeline

**To v2.0.0 Release**: 4-6 hours
- Infrastructure fixes: 2-3 hours
- Documentation: 1-2 hours  
- Testing: 1 hour
- Release: 30 min

**To v2.1.0** (Style system): 2-3 weeks after v2.0

**To v2.2.0** (HTML import): 1-2 weeks after v2.1

## Development Process

### For Priority 1 (Infrastructure)

1. Read current ContentTypes and Relationships classes
2. Implement missing methods if needed
3. Fix `add_required_files()` 
4. Run round-trip tests
5. Iterate until 10/10 passing

### For Priority 3 (Documentation)

1. Write v2.0 section in README.adoc
2. Create new docs in `docs/`
3. Move old docs to `old-docs/`
4. Update examples in `examples/`

### For Priority 5 (Release)

1. Verify all tests pass
2. Update version and changelog
3. Build gem
4. Test gem in clean environment
5. Push to RubyGems
6. Announce on GitHub

## Contact & Questions

**Current Blocker**: None
**Next Step**: Fix [Content_Types].xml generation
**ETA to Release**: 4-6 hours of focused work

---

**Document Status**: Active
**Last Updated**: November 28, 2024
**Next Review**: After Priority 1 complete