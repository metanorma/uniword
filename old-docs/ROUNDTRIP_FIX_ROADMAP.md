# Round-Trip Fix Roadmap

**Purpose**: Systematic plan to fix all 13 round-trip test failures revealed by Canon

**Test File**: [`spec/uniword/roundtrip_demo_spec.rb`](spec/uniword/roundtrip_demo_spec.rb)

**Current Status**: 12 failures, 2 pending, 2 passing (document loading + webSettings.xml)

---

## Quick Wins (30 minutes) - Start Here

### 1. Fix docProps/core.xml ✅ EASY
**Issue**: Title says "Untitled", creator/modifiedBy say "Uniword"
**Canon Shows**: Lines 2-10 differ
**Fix**: [`lib/uniword/serialization/ooxml_serializer.rb`](lib/uniword/serialization/ooxml_serializer.rb) `build_core_properties_xml`:
```ruby
# Read metadata from document if present
title = document.respond_to?(:metadata) && document.metadata[:title] ? document.metadata[:title] : ''
creator = document.respond_to?(:metadata) && document.metadata[:creator] ? document.metadata[:creator] : 'Uniword'
```

### 2. Fix docProps/app.xml ✅ EASY
**Issue**: Stats wrong (0 words vs 923 words), element order
**Canon Shows**: Lines 3-14 differ
**Fix**: Calculate real stats from document content

### 3. Fix webSettings.xml ✅ EASY
**Issue**: Missing `mc:Ignorable` attribute
**Canon Shows**: Line 1 differs
**Fix**: Add namespace attribute to root element
**Status**: ✅ COMPLETE - Fixed in lib/uniword/serialization/ooxml_serializer.rb

**Status**: ✅ COMPLETE - All unit tests passing

---

## Medium Difficulty (1-2 hours)

### 4. Fix _rels/.rels ✅ MEDIUM
**Issue**: Wrong relationship order, duplicates
**Canon Shows**: Lines 2-8 differ
**Need**: Consistent relationship ID assignment

### 5. Fix [Content_Types].xml ✅ MEDIUM
**Issue**: Element ordering differs
**Canon Shows**: 20 differences
**Need**: Match exact order from reference

### 6. Fix word/_rels/document.xml.rels ✅ MEDIUM
**Issue**: Relationship ID order
**Canon Shows**: 6 differences
**Need**: Match reference order

### 7. Fix word/fontTable.xml ⚠️ MEDIUM-HARD
**Issue**: Missing fonts (Symbol, Times New Roman), wrong order
**Canon Shows**: Lines 2-37 missing fonts
**Need**: **Deserializer** must parse fontTable.xml and preserve fonts

---

## Deserializer Work Required (2-4 hours)

### 8. Fix word/numbering.xml ⚠️ HARD
**Issue**: Missing entire abstractNum definition (96% data loss)
**Canon Shows**: Lines 2-26 all missing
**Need**:
- **Deserializer** parse numbering.xml
- Create NumberingDefinition objects
- Preserve in document.numbering_configuration`
- **Serializer** already exists (build_numbering_xml)

**Current State**: Deserializer only creates empty numbering config

### 9. Fix word/settings.xml ⚠️ HARD
**Issue**: 93% data loss, many elements missing
**Canon Shows**: Lines 2-58 missing
**Need**:
- **Deserializer** parse settings.xml completely
- Create Settings model object
- Store in document
- Enhance **Serializer** build_settings_xml

### 10. Fix word/theme/_rels/theme1.xml.rels ⚠️ HARD
**Issue**: Missing image relationship
**Canon Shows**: Lines 2-3 missing
**Need**:
- **Deserializer** extract media from loaded .docx
- Parse theme/_rels/theme1.xml.rels
- Store media in theme.media_files
- **Serializer** add relationship (already done)

---

## Complex Enhancements (4+ hours)

### 11. Fix word/styles.xml ⚠️ VERY HARD
**Issue**: 68% data loss (45KB → 14KB)
**Cause**: Only serializing StyleSet-loaded styles, not preserving loaded styles
**Need**:
- **Deserializer** must parse ALL style elements
- Including style properties we enhanced in Week 1
- Test with our enhanced parser

### 12. Fix word/theme/theme1.xml ⚠️ VERY HARD
**Issue**: 78% data loss (7KB → 1.5KB)
**Canon Shows**: Lines 30-265 missing (effect schemes!)
**Cause**: Our theme parser only gets colors & fonts
**Need**:
- **Deserializer** parse fillStyleLst, lnStyleLst, effectStyleLst, bgFillStyleLst
- Create EffectScheme model objects
- Enhance ThemeXmlParser
- Enhance build_theme_xml to serialize effects

### 13. Fix word/document.xml ⚠️ MINOR
**Issue**: 0.6% growth (likely OK)
**Canon Shows**: Different but stable
**Action**: Verify after other fixes

---

## Implementation Order

### Phase 1: Quick Wins (30 min)
1. webSettings.xml - Add mc:Ignorable
2. docProps/*.xml - Fix metadata values
3. Run tests: 3/13 → 6/13 passing

### Phase 2: Relationship Fixes (1 hour)
4. Fix all .rels files ordering
5. Fix [Content_Types].xml ordering
6. Run tests: 6/13 → 9/13 passing

### Phase 3: Deserializer Core (2-3 hours)
7. Parse fontTable.xml completely
8. Parse numbering.xml completely
9. Parse settings.xml completely
10. Extract theme media from .docx
11. Run tests: 9/13 → 12/13 passing

### Phase 4: Complex (4+ hours)
12. Parse complete theme (effect schemes)
13. Verify styles preservation
14. Run tests: 12/13 → 13/13 passing

---

## Success Criteria

**Target**: All 13 round-trip tests passing with Canon verification

**Current**: 1/13 passing (1 quick win fixed)

**Goal**: 13/13 passing (Next week:天文和ISO 8601，第三周數據模型，第四周開啟文件和打照片)

**Then**: Proceed to Week 2 Days 2-5 (Math namespace + Bookmarks + ISO 8601)

---

## Today's Achievement Summary

**Completed**:
- ✅ Week 1: StyleSet system (100%)
- ✅ Week 2 Day 1: Infrastructure (100%)
- ✅ Round-trip test framework (Canon-powered)
- ✅ Gap analysis (13 files, line-by-line)

**Next Session**:
- Fix quick wins (Phase 1)
- Fix relationships (Phase 2)
- Begin deserializer work (Phase 3)

**This roadmap provides exact steps for achieving perfect round-trip!**
