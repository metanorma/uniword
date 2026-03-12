# lutaml-model v0.7.7 Migration - Fix All Failures Plan

## Current Status

**Test Results**: `3198 examples, 805 failures, 246 pending`

**Progress**: Started at 1101 → 958 → 886 → 857 → 853 → 851 → 850 → 846 → 821 → 809 → 805 failures
**Total Fixed**: 296 failures (~26.9% reduction)

## Remaining Error Patterns

### High Priority (Spec Issues)

| Error Pattern | Approx Count | Fix Strategy |
|---------------|--------------|--------------|
| `undefined method 'value' for true` | ~20 | Use predicate methods (`bold?`, `italic?`, etc.) |
| `undefined method 'value' for String` | ~5 | Use safe navigation `&.value` |
| `undefined method 'value' for Integer` | ~3 | Use safe navigation `&.value` |
| `undefined method 'type' for String` | ~3 | Check spec expectations |

### Medium Priority (Missing Methods)

| Method | Class | Status |
|--------|-------|--------|
| `add_image` | Run | Need to add |
| `cell_padding` | TableProperties | Need to add |
| `comments` | DocumentRoot | Need to add |
| `compact` | Metadata | Need to add |
| `create_numbering` | Document | Need to add |
| `enable_debug_logging` | Uniword module | Need to add |
| `disable_debug_logging` | Uniword module | Need to add |
| `font_family` | Style | Need to add |
| `spacing_before` | Style | Need to add |
| `stream` | DocumentRoot | Need to add |
| `revisions` | DocumentRoot | Need to add |

### Low Priority (Nil-Safe Access)

These are specs that call methods on nil objects - need to update specs:
- `bold?` for nil (3)
- `italic?` for nil (1)
- `underline` for nil (1)
- `hyperlink` for nil (3)
- `font` for nil (1)
- `color` for nil (1)
- `font_size` for nil (1)
- `cells` for nil (1)

## Implementation Tasks

### Phase 1: Fix Remaining `.value` Errors
- [x] Fix boolean `.value` calls (completed by background agents)
- [x] Fix String `.value` calls (completed by background agents)
- [x] Fix Integer `.value` calls (completed by background agents)
- [ ] Verify all `.value` errors are fixed

### Phase 2: Add Missing Methods
- [ ] Add `add_image` to Run class
- [ ] Add `cell_padding` to TableProperties
- [ ] Add `comments` getter to DocumentRoot
- [ ] Add `compact` to Metadata
- [ ] Add `create_numbering` to Document/Body
- [ ] Add debug logging methods to Uniword module
- [ ] Add `font_family` to Style
- [ ] Add `spacing_before` to Style
- [ ] Add `stream` to DocumentRoot
- [ ] Add `revisions` to DocumentRoot

### Phase 3: Fix Nil-Safe Access Issues
- [ ] Update specs to use safe navigation for potentially nil properties
- [ ] Add nil checks where appropriate

### Phase 4: Round-Trip Testing
- [ ] Run complete round-trip tests
- [ ] Fix any remaining XML serialization issues
- [ ] Verify all DOCX files round-trip correctly

## Files Modified This Session

### Implementation Files
- `lib/uniword/wordprocessingml/run_properties.rb` - Added predicate methods, font_size, font_color, emboss, imprint methods
- `lib/uniword/wordprocessingml/paragraph.rb` - Added extract_current_properties, each_text_run, alignment, spacing_before, add_image methods
- `lib/uniword/wordprocessingml/run.rb` - Added font_size, font, color, emboss, imprint methods
- `lib/uniword/wordprocessingml/paragraph_properties.rb` - Added left_indent= method

### Spec Files Updated (by agents)
- Multiple spec files updated to use predicate methods
- Multiple spec files updated to use safe navigation operator

## Next Steps

1. Run tests to verify current failure count
2. Address remaining `.value` on primitive errors
3. Add missing methods to classes
4. Update specs for nil-safe access
5. Run full test suite
6. Document changes in README.adoc
