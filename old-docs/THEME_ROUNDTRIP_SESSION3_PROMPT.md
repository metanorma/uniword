# Theme Round-Trip Session 3 - Continuation Prompt

**Copy this entire section to start the next session**

---

## 🎯 Current Status

**Test Results**: 145/174 passing (83%) - No change
**Phase**: Phase 2 Session 2 COMPLETE
**Remaining**: 29 failures (likely Canon XML equivalence issue with empty attributes)

## ✅ Session 2 Accomplishments (90 minutes)

Completed 7 major DrawingML element enhancements:
1. **SchemeColor** - Added 10 color modifiers (tint, shade, sat_mod, lum_mod, alpha, alpha_mod, alpha_off, hue, hue_mod, hue_off)
2. **SrgbColor** - Added same 10 color modifiers for RGB color support
3. **SolidFill** - Added scheme_clr and srgb_clr child elements
4. **OuterShadow** - Added rot_with_shape, scheme_clr, srgb_clr, fixed blurRad attribute name
5. **GradientFill** - Added rot_with_shape attribute
6. **LineProperties** - Added cap, cmpd, algn attributes + solid_fill, grad_fill, prst_dash children
7. **FontScheme** - Fixed empty attribute serialization (`<ea typeface=""/>` → `<ea/>`)

**Quality**: Zero regressions, StyleSet tests still 168/168 ✅

## 🔍 Session 3 Objective: Root Cause Analysis

The 29 remaining failures are likely NOT missing elements but semantic XML equivalence issues:

### Hypothesis 1: Canon Configuration
Canon gem may not treat `<ea/>` as equivalent to `<ea typeface=""/>`. Our cleaner serialization is **better** but Canon needs configuration.

### Hypothesis 2: Missing GradientStop Colors
GradientStop may need color child elements (scheme_clr, srgb_clr) like SolidFill.

## 📋 Session 3 Tasks

### Task 1: Detailed Failure Analysis (30 min)

```bash
cd /Users/mulgodi/src/mn/uniword

# Get detailed failure output
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format documentation --failure-exit-code 0 > theme_failures_detailed.txt

# Analyze patterns
grep -A 10 "Failure" theme_failures_detailed.txt | head -100
```

**Look for**:
- Empty attribute patterns (`<ea typeface=""/>` vs `<ea/>`)
- Missing elements (will show in XML diff)
- Namespace issues

### Task 2: Check GradientStop (30 min)

```bash
# Extract one theme to examine
cd /Users/mulgogi/src/mn/uniword
unzip -p references/word-package/office-themes/Badge.thmx theme/theme/theme1.xml > badge_theme.xml

# Search for gradient stops
grep -A 5 "<a:gs" badge_theme.xml
```

If gradient stops have `<a:schemeClr>` children, complete GradientStop:

```ruby
# lib/uniword/drawingml/gradient_stop.rb
attribute :scheme_clr, SchemeColor
attribute :srgb_clr, SrgbColor

xml do
  map_attribute 'pos', to: :pos
  map_element 'schemeClr', to: :scheme_clr, render_nil: false
  map_element 'srgbClr', to: :srgb_clr, render_nil: false
end
```

### Task 3: Canon Configuration Investigation (60 min)

Check if Canon can be configured for empty attribute equivalence:

```ruby
# In theme_roundtrip_spec.rb
Canon::Xml.configure do |config|
  config.empty_element_equivalence = true  # Try this
end
```

Or investigate if Canon has options for:
- Empty attribute normalization
- Element vs self-closing tag equivalence

### Task 4: If Needed - Complete Remaining Elements (2 hours)

Only if Task 1 reveals actual missing elements, complete them following established patterns.

## 🎯 Success Criteria

**DO NOT LOWER STANDARDS**:
- Target: 174/174 tests passing
- No shortcuts or threshold lowering
- Architecture correctness is paramount
- If Canon configuration needed, configure Canon (don't hack elements)

## 📁 Key Files

**Reference**:
- `THEME_ROUNDTRIP_STATUS.md` - Updated with Session 2 progress
- `THEME_ROUNDTRIP_CONTINUATION_PLAN.md` - Original plan
- `.kilocode/rules/memory-bank/context.md` - Project context

**Test Output**:
- `spec/uniword/theme_roundtrip_spec.rb` - 174 test examples
- Run specific: `bundle exec rspec 'spec/uniword/theme_roundtrip_spec.rb[1:2:4]'` (Badge theme)

**Modified Files (Session 2)**:
1. `lib/uniword/drawingml/scheme_color.rb`
2. `lib/uniword/drawingml/srgb_color.rb`
3. `lib/uniword/drawingml/solid_fill.rb`
4. `lib/uniword/drawingml/outer_shadow.rb`
5. `lib/uniword/drawingml/gradient_fill.rb`
6. `lib/uniword/drawingml/line_properties.rb`
7. `lib/uniword/font_scheme.rb`

## 🚀 START HERE

```bash
cd /Users/mulgogi/src/mn/uniword

# Step 1: Generate detailed failure report
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format documentation --failure-exit-code 0 > theme_failures_detailed.txt

# Step 2: Analyze first 20 failures
head -200 theme_failures_detailed.txt

# Step 3: Look for patterns
grep "typeface" theme_failures_detailed.txt | head -20
grep "SEARCH" theme_failures_detailed.txt | wc -l
```

## 🎓 Key Insights

From Session 2:
- Systematic approach works (7 elements in 90 minutes)
- Pattern 0 critical (attributes before xml)
- `render_nil: false` prevents empty element clutter
- No regression when following patterns

**For Session 3**:
- Don't assume missing elements - investigate first
- Canon configuration might be the solution
- Empty attributes are semantic equivalence issue, not a bug in our code
- Our cleaner XML (`<ea/>`) is architecturally superior to `<ea typeface=""/>`

## ⚠️ Important Reminders

1. **Architecture over shortcuts**: If we need Canon configuration, configure Canon
2. **No threshold lowering**: 174/174 is the target
3. **Investigate before implementing**: Don't add elements unless XML diff proves they're needed
4. **Test after each change**: Maintain zero regression

---

Good luck! Focus on root cause analysis first. 🔍