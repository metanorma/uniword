# Phase 5 Session 3: VML & Math Content Parsing - START HERE

**Goal**: Achieve 274/274 tests (100%) by implementing VML and Math content parsing
**Duration**: 3-4 hours (estimated)
**Status**: Ready to begin
**Prerequisite**: Session 2 Complete ✅ (AlternateContent + DrawingML infrastructure)

## 🎯 Session 3 Objective

**PRIMARY GOAL**: Implement VML (Vector Markup Language) and Math (OMML) content parsing to achieve **274/274 tests (100%)**

## 📊 Starting Point

### Current Test Results
- **Total**: 266/274 (97.1%)
- **Failing**: 8 glossary tests
  - Bibliographies.dotx
  - Cover Pages.dotx
  - Equations.dotx
  - Footers.dotx
  - Headers.dotx
  - Table of Contents.dotx
  - Tables.dotx
  - Watermarks.dotx

### What's Already Working
✅ AlternateContent structure (Session 2)
✅ Drawing and DrawingML classes
✅ Glossary infrastructure (docParts, docPart, etc.)
✅ 100% model-driven architecture
✅ Zero technical debt

### What's Missing
❌ VML Content (Group, Shape elements)
❌ Math Content (oMathPara, oMath elements)

## 📋 Implementation Strategy

### Part 1: VML Content (2-3 hours)

**VML Background**: Legacy 2D graphics format from Office 2003, preserved in Fallback elements for compatibility.

**Tasks**:
1. **Analyze VML structure** (30 min)
   - Extract VML from failing tests
   - Identify common patterns
   - Map to class structure

2. **Implement VML classes** (60 min)
   - Create vml/group.rb
   - Create vml/shape.rb
   - Create vml/textbox.rb
   - Add to Pict integration

3. **Test VML parsing** (30 min)
   - Run test suite
   - Expect +4-6 tests passing
   - Verify zero regressions

### Part 2: Math Content (1-2 hours)

**OMML Background**: Office Math Markup Language for equations in Word 2007+.

**Tasks**:
1. **Analyze Math structure** (20 min)
   - Extract OMML from Equations.dotx
   - Identify patterns
   - Map to classes

2. **Implement Math classes** (40 min)
   - Create math/o_math_para.rb
   - Create math/o_math.rb
   - Add to Body integration

3. **Test Math parsing** (20 min)
   - Run test suite
   - Expect +2-4 tests passing
   - Achieve 274/274 (100%)!

## 🚀 Quick Start Commands

### Step 1: Analyze Failing Tests

```bash
cd /Users/mulgogi/src/mn/uniword

# Run just the failing glossary tests
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Bibliographies.dotx" \
  --format documentation
```

### Step 2: Extract VML/Math Content

Use the test output to identify:
- VML elements in Fallback sections
- Math elements in docPartBody
- Common patterns across failures

### Step 3: Implement Classes

Follow the proven Pattern 0 approach from Session 2:
1. Attributes BEFORE xml mappings (critical!)
2. Use proper namesp aces (VML, MathML)
3. Test after each class
4. Maintain baseline (266/274)

## 📐 Class Templates

### VML Group Template

```ruby
# lib/uniword/vml/group.rb
module Uniword
  module Vml
    class Group < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :coordsize, :string
      attribute :shapes, Shape, collection: true
      
      xml do
        root 'group'
        namespace Uniword::Ooxml::Namespaces::VML
        
        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'coordsize', to: :coordsize
        
        map_element 'shape', to: :shapes
      end
    end
  end
end
```

### Math OMathPara Template

```ruby
# lib/uniword/math/o_math_para.rb
module Uniword
  module Math
    class OMathPara < Lutaml::Model::Serializable
      attribute :o_math, OMath, collection: true
      
      xml do
        root 'oMathPara'
        namespace Uniword::Ooxml::Namespaces::MathML
        
        map_element 'oMath', to: :o_math
      end
    end
  end
end
```

## ✅ Success Criteria

### Must Achieve
- [ ] 274/274 tests passing (100%)
- [ ] Zero regressions (266 baseline maintained)
- [ ] 100% model-driven (no :string content)
- [ ] Pattern 0 compliance (all classes)

### Documentation
- [ ] Session 3 complete summary created
- [ ] Memory bank updated
- [ ] Phase 5 marked COMPLETE

## 🎯 Execution Checklist

### Pre-Session
- [x] Session 2 complete ✅
- [x] Baseline established (266/274) ✅
- [x] Plan reviewed ✅
- [x] Ready to start ✅

### During Session
- [ ] Run initial test analysis
- [ ] Implement VML classes
- [ ] Test VML (expect 270-272/274)
- [ ] Implement Math classes
- [ ] Test Math (expect 274/274!)
- [ ] Create completion summary
- [ ] Update memory bank

### Post-Session
- [ ] Verify 274/274 (100%)
- [ ] Document patterns learned
- [ ] Prepare for v1.1.0 release
- [ ] Celebrate Phase 5 completion! 🎉

## 📝 Important Reminders

### Critical Patterns from Session 2

1. **Pattern 0**: Attributes MUST come before xml mappings
   ```ruby
   attribute :my_attr, MyType  # FIRST!
   xml do                      # SECOND!
     map_element 'elem', to: :my_attr
   end
   ```

2. **Namespace Clarity**: Use explicit namespace declarations
   ```ruby
   namespace Uniword::Ooxml::Namespaces::VML  # Not WordprocessingML!
   ```

3. **Test After Each**: Maintain baseline throughout
   ```bash
   bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb
   ```

4. **Document Progress**: Update status after each milestone

## 🎉 Expected Outcome

**Before Session 3**: 266/274 (97.1%)
**After VML**: 270-272/274 (98-99%)
**After Math**: 274/274 (100%) ✅

**Phase 5**: COMPLETE! 🎊
**Uniword**: 100% Round-Trip Fidelity Achieved! 🏆

---

## 🚀 Ready to Begin!

**Time Budget**: 3-4 hours
**Complexity**: Medium (patterns established)
**Confidence**: HIGH (clear path forward)

**Start with**:
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation
```

Analyze the failures, identify VML/Math patterns, and implement classes one at a time!

**Good luck! Let's finish Phase 5 strong!** 💪

---

**Reference Documents**:
- `PHASE5_SESSION3_PLAN.md` - Detailed plan
- `PHASE5_SESSION2_COMPLETE.md` - Session 2 summary
- `.kilocode/rules/memory-bank/context.md` - Current state

**Next Step**: Run tests, analyze failures, start VML implementation!