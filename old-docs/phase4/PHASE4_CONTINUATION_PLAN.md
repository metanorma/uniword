# Phase 4: Wordprocessingml Property Completeness - Continuation Plan

**Created**: December 2, 2024
**Status**: Session 1 Complete, Session 2+ Ready
**Priority**: HIGH - Complete all 27 property gaps for 100% round-trip fidelity

## Executive Summary

Phase 4 implements complete Wordprocessingml property support to achieve 100% round-trip fidelity for all 61 reference files. Session 1 completed the foundation (4 high-priority properties), reducing test differences by 23%. Remaining work: 23 properties across 6 hours estimated.

## Current State (Session 1 Complete)

### Completed (6 items) ✅
1. ✅ Property Analysis - 27 gaps identified and prioritized
2. ✅ Shading themeFill enhancement
3. ✅ TableWidth wrapper class
4. ✅ CellWidth wrapper class
5. ✅ CellVerticalAlign wrapper class
6. ✅ TableCellProperties integration

### Test Results
- **Before**: 276 differences per test
- **After**: 211 differences per test
- **Improvement**: -23% reduction
- **Status**: 8/16 tests passing (Content Types only)

## Remaining Work (21 items)

### Session 2: Complete Table Properties (2 hours)

**Priority**: HIGH - Affects all 8/8 glossary tests

#### Tasks
1. **TableCellMargin + Margin Classes** (45 min)
   - Create `lib/uniword/properties/margin.rb` (helper class)
   - Create `lib/uniword/properties/table_cell_margin.rb`
   - Attributes: top, bottom, left, right (each a Margin)
   - Margin has: w (integer), type (string: dxa)

2. **TableLook Class** (30 min)
   - Create `lib/uniword/properties/table_look.rb`
   - Attributes: val, firstRow, lastRow, firstColumn, lastColumn, noHBand, noVBand
   - All attributes are booleans or hex string (val)

3. **GridColumn Enhancement** (20 min)
   - Update `lib/uniword/table_grid_column.rb` or wordprocessingml equivalent
   - Add w (width) attribute

4. **TableProperties Integration** (25 min)
   - Add table_cell_margin attribute
   - Add table_look attribute
   - Update XML mappings
   - Verify serialization

**Expected Outcome**: 50+ fewer differences per test

### Session 3: Run Properties Enhancement (1.5 hours)

**Priority**: MEDIUM - Affects 6/8 tests

#### Tasks
1. **Run Caps Property** (15 min)
   - Add caps boolean flag to RunProperties
   - XML mapping for `<w:caps/>`

2. **Run NoProof Property** (15 min)
   - Add no_proof boolean flag to RunProperties
   - XML mapping for `<w:noProof/>`

3. **Color themeColor Enhancement** (20 min)
   - Update `lib/uniword/properties/color_value.rb`
   - Add theme_color attribute (string)
   - XML mapping for `themeColor` attribute

4. **Complex Script Size** (15 min)
   - Ensure szCs handling in `lib/uniword/properties/font_size.rb`
   - May need separate ComplexScriptSize class
   - XML mapping for `<w:szCs>`

5. **RunProperties Integration** (25 min)
   - Integrate all 4 new properties
   - Update XML mappings
   - Test serialization

**Expected Outcome**: 30+ fewer differences per test

### Session 4: Paragraph rsid Attributes (30 min)

**Priority**: MEDIUM - Affects 6/8 tests

#### Tasks
1. **Paragraph Class Enhancement**
   - Find `lib/uniword/wordprocessingml/paragraph.rb` or equivalent
   - Add rsidR, rsidRDefault, rsidP attributes (all :string)
   - Update XML mappings with `map_attribute`

**Expected Outcome**: 20+ fewer differences per test

### Session 5: SDT Properties Architecture (2.5 hours)

**Priority**: LOW - Affects 3/8 tests (but complete infrastructure)

#### Directory Structure
```
lib/uniword/sdt/
├── id.rb
├── alias.rb
├── tag.rb
├── appearance.rb
├── text.rb
├── doc_part_object.rb
├── placeholder.rb
├── data_binding.rb
└── showing_placeholder_header.rb
```

#### Tasks (in priority order)

1. **Create lib/uniword/sdt/ directory** (5 min)

2. **SDT Id Class** (15 min)
   - Unique integer identifier
   - XML: `<w:id w:val="-578829839"/>`

3. **SDT Alias Class** (15 min)
   - Display name
   - XML: `<w:alias w:val="Title"/>`

4. **SDT Tag Class** (15 min)
   - Developer tag value (can be empty)
   - XML: `<w:tag w:val=""/>`

5. **SDT ShowingPlaceholderHeader** (10 min)
   - Boolean flag (presence indicates true)
   - XML: `<w:showingPlcHdr/>`

6. **SDT Text Control** (10 min)
   - Text box control flag
   - XML: `<w:text/>`

7. **SDT Appearance Class** (20 min)
   - Visual appearance mode
   - Values: hidden, tags, boundingBox
   - XML: `<w:appearance w:val="hidden"/>`

8. **SDT Placeholder Class** (20 min)
   - References docPart
   - XML: `<w:placeholder><w:docPart w:val="..."/></w:placeholder>`

9. **SDT DataBinding Class** (30 min)
   - Complex attributes: xpath, storeItemID, prefixMappings
   - XML: `<w:dataBinding w:xpath="..." w:storeItemID="..." w:prefixMappings="..."/>`

10. **StructuredDocumentTagProperties Integration** (30 min)
    - Find or create `lib/uniword/structured_document_tag_properties.rb`
    - Integrate all 8 SDT property classes
    - Update XML mappings
    - Test serialization

**Expected Outcome**: Complete SDT support, 60+ fewer differences for 3 tests

### Session 6: Testing & Verification (1 hour)

**Priority**: CRITICAL - Ensure quality

#### Tasks
1. **Integration Testing** (20 min)
   - Run all document element tests
   - Target: 16/16 passing
   - Analyze remaining failures

2. **Regression Testing** (20 min)
   - Run baseline tests (342 StyleSet + Theme tests)
   - Must maintain: 342/342 passing
   - Fix any regressions immediately

3. **Final Verification** (20 min)
   - Review all 27 implemented properties
   - Verify Pattern 0 compliance (100%)
   - Verify MECE architecture
   - Verify zero raw XML

### Session 7: Documentation (30 min)

**Priority**: MEDIUM - Record achievements

#### Tasks
1. **Update Memory Bank** (10 min)
   - Update `context.md` with Phase 4 completion
   - Document new property classes
   - Update test status

2. **Update README.adoc** (15 min)
   - Document Phase 4 completion
   - List all 27 new/enhanced properties
   - Update examples if needed

3. **Cleanup** (5 min)
   - Move temporary docs to `old-docs/`
   - Organize analysis documents

## Implementation Principles

### Architecture (CRITICAL)
- ✅ **Pattern 0**: ALWAYS attributes before xml mappings
- ✅ **MECE**: Clear separation of concerns
- ✅ **Model-Driven**: No raw XML preservation
- ✅ **OOP**: Proper inheritance and polymorphism
- ✅ **Extensibility**: Open/closed principle

### Quality Standards
- ✅ Every property must be a lutaml-model class
- ✅ Every property must follow Pattern 0
- ✅ Every property must have proper XML mappings
- ✅ Test after each implementation
- ✅ Zero regressions tolerated

### Efficiency Tactics
1. **Batch Related Changes**: Implement related properties together
2. **Test Frequently**: Catch issues early
3. **Follow Proven Pattern**: Session 1 pattern works perfectly
4. **Document As You Go**: Don't defer documentation

## Time Estimates

| Session | Focus | Estimated Time | Status |
|---------|-------|----------------|--------|
| Session 1 | High-Priority Properties | 1.5 hours | ✅ Complete |
| Session 2 | Complete Table Properties | 2 hours | ⏳ Next |
| Session 3 | Run Properties | 1.5 hours | ⏳ Planned |
| Session 4 | Paragraph rsid | 30 min | ⏳ Planned |
| Session 5 | SDT Properties | 2.5 hours | ⏳ Planned |
| Session 6 | Testing & Verification | 1 hour | ⏳ Planned |
| Session 7 | Documentation | 30 min | ⏳ Planned |
| **Total** | **Complete Phase 4** | **9.5 hours** | **15% Done** |

**Compressed Timeline**: With focused effort, can complete in 3-4 work sessions over 2 days

## Success Criteria

### Primary Goals
- [ ] All 27 properties implemented
- [ ] 16/16 document element tests passing
- [ ] 342/342 baseline tests maintained
- [ ] 100% Pattern 0 compliance
- [ ] Zero raw XML

### Secondary Goals
- [ ] Documentation updated
- [ ] Memory bank current
- [ ] Temporary docs archived
- [ ] Examples verified

## Risk Mitigation

### Known Risks
1. **Regression Risk**: Mitigate with frequent testing
2. **Time Overrun**: Prioritize high-impact properties first
3. **Complexity Risk**: Follow proven patterns from Session 1
4. **Integration Issues**: Test each property individually

### Contingency Plans
- If Session 2 takes > 2.5 hours, defer GridColumn to Session 3
- If SDT implementation exceeds 3 hours, implement core properties only
- If regressions occur, rollback and re-analyze

## Next Session Prompt

```
Continue Phase 4 Session 2: Complete Table Properties

Implement the remaining table properties to maximize test improvements:

1. Create TableCellMargin + Margin wrapper classes
2. Create TableLook wrapper class  
3. Enhance GridColumn with width attribute
4. Integrate all into TableProperties
5. Run tests and verify 50+ fewer differences

Reference documents:
- Plan: PHASE4_CONTINUATION_PLAN.md
- Status: PHASE4_IMPLEMENTATION_STATUS.md
- Session 1: PHASE4_SESSION1_SUMMARY.md
- Analysis: PHASE4_PROPERTY_ANALYSIS.md

Current baseline: 211 differences per test (down from 276)
Target: <160 differences per test after Session 2
```

## Files to Track

### Created in Session 1
- ✅ PHASE4_PROPERTY_ANALYSIS.md
- ✅ PHASE4_SESSION1_SUMMARY.md
- ✅ lib/uniword/properties/table_width.rb
- ✅ lib/uniword/properties/cell_width.rb
- ✅ lib/uniword/properties/cell_vertical_align.rb

### To Create in Future Sessions
- [ ] lib/uniword/properties/margin.rb
- [ ] lib/uniword/properties/table_cell_margin.rb
- [ ] lib/uniword/properties/table_look.rb
- [ ] lib/uniword/sdt/*.rb (8 files)
- [ ] PHASE4_COMPLETION_REPORT.md (final)

### To Update
- [ ] lib/uniword/ooxml/wordprocessingml/table_properties.rb (complete)
- [ ] lib/uniword/properties/color_value.rb (add themeColor)
- [ ] lib/uniword/properties/run_properties.rb (add 4 properties)
- [ ] lib/uniword/wordprocessingml/paragraph.rb (add rsid attributes)
- [ ] README.adoc (document Phase 4)
- [ ] .kilocode/rules/memory-bank/context.md (update status)

## Conclusion

Phase 4 is on track for completion within the 2-day compressed timeline. Session 1 established solid architectural patterns that will enable rapid implementation of remaining properties. The 23% reduction in test differences validates our approach. With focused execution, we'll achieve 100% round-trip fidelity for all 61 reference files.

**Status**: Foundation Complete, Ready for Session 2 ✅