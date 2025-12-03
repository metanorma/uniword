# Phase 5 Session 3: VML & Math Content Parsing - COMPLETE PLAN

**Goal**: Achieve 274/274 tests (100%) by implementing VML and Math content parsing
**Duration**: 3-4 hours (compressed timeline)
**Status**: Ready to Begin
**Prerequisites**: Session 2 Complete ✅ (AlternateContent + DrawingML infrastructure in place)

## 📊 Current State

### Test Results
- **Total**: 266/274 (97.1%)
- **StyleSets**: 168/168 (100%) ✅
- **Themes**: 174/174 (100%) ✅
- **Document Elements**: 8/16 (50%)
  - Content Types: 8/8 (100%) ✅
  - Glossary: 0/8 (0% - needs Session 3)

### What's Working
- ✅ AlternateContent structure serializes correctly
- ✅ Glossary infrastructure complete (docParts, docPart, docPartPr, docPartBody)
- ✅ Basic paragraph and run structure intact
- ✅ SDT structure present (but content not parsed)

### What's Missing (8 Glossary Tests)

**Analysis of failures shows TWO categories**:

1. **VML Content** (6-7 tests affected):
   - Cover Pages, Headers, Footers, Watermarks contain VML shapes
   - Tables contains VML borders/decorative elements  
   - Equations may have VML fallback

2. **Math Content** (1-2 tests affected):
   - Equations.dotx has actual math equations (OMML)
   - May appear in Bibliography fields

## 🎯 Session 3 Objectives

### Primary Goal
Implement VML and Math content parsing to achieve **274/274 tests (100%)**

### Secondary Goals
1. Maintain 100% model-driven architecture (no raw XML)
2. Zero regressions on existing 266 tests
3. Complete Phase 5 successfully
4. Document all patterns for future reference

## 📋 Implementation Plan

### Part 1: VML Content Parsing (2-3 hours)

#### VML Background
VML (Vector Markup Language) is Microsoft's legacy 2D graphics format used in Office 2003 and earlier. It's preserved in AlternateContent Fallback for compatibility.

**Key VML Elements**:
- `<v:group>` - Container for multiple shapes
- `<v:shape>` - Individual shape definition
- `<v:shapetype>` - Reusable shape template
- `<v:textbox>` - Text within shapes
- `<o:*>` - Office extensions (wrap, lock, etc.)

#### Step 1.1: Analyze VML Structure (30 min)

**Tasks**:
1. Extract VML content from failing glossary documents
2. Identify common VML patterns
3. Map VML elements to class structure
4. Determine namespace requirements

**Expected Patterns**:
```xml
<mc:Fallback>
  <w:pict>
    <v:group>
      <v:shape style="..." type="#_x0000_t202">
        <v:textbox>
          <w:txbxContent>
            <w:p>...</w:p>
          </w:txbxContent>
        </v:textbox>
      </v:shape>
    </v:group>
  </w:pict>
</mc:Fallback>
```

#### Step 1.2: Implement VML Core Classes (60 min)

**Create**:
1. `lib/uniword/vml/group.rb` - Group container
2. `lib/uniword/vml/shape.rb` - Shape element
3. `lib/uniword/vml/shapetype.rb` - Shape template
4. `lib/uniword/vml/textbox.rb` - Text container
5. `lib/uniword/vml/txbx_content.rb` - Textbox content

**Pattern** (Example for Group):
```ruby
module Uniword
  module Vml
    class Group < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :shapes, Shape, collection: true
      
      xml do
        root 'group'
        namespace Uniword::Ooxml::Namespaces::VML
        
        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'coordsize', to: :coordsize
        map_attribute 'coordorigin', to: :coordorigin
        
        map_element 'shape', to: :shapes
      end
    end
  end
end
```

**Key Considerations**:
- Use VML namespace (`v:`) not WordprocessingML
- Office namespace (`o:`) for extensions
- Style attribute is complex but can be string initially
- Collection support for nested shapes

#### Step 1.3: Integrate VML into Pict (30 min)

**Modify**: `lib/uniword/wordprocessingml/pict.rb`

**Changes**:
```ruby
attribute :group, Vml::Group
attribute :shape, Vml::Shape 
attribute :shapetype, Vml::Shapetype

xml do
  map_element 'group', to: :group,
              namespace: Uniword::Ooxml::Namespaces::VML
  map_element 'shape', to: :shape,
              namespace: Uniword::Ooxml::Namespaces::VML
  map_element 'shapetype', to: :shapetype,
              namespace: Uniword::Ooxml::Namespaces::VML
end
```

#### Step 1.4: Test VML Parsing (30 min)

**Validate**:
1. Run full test suite
2. Check glossary improvements
3. Verify zero regressions
4. Document any remaining gaps

**Expected Improvement**: +4-6 tests (Cover Pages, Headers, Footers, Watermarks, Tables)

### Part 2: Math Content Parsing (1-2 hours)

#### Math Background
OMML (Office Math Markup Language) is Microsoft's XML format for mathematical equations. Used in Word 2007+.

**Key OMML Elements**:
- `<m:oMathPara>` - Math paragraph container
- `<m:oMath>` - Math expression
- `<m:r>` - Math run
- `<m:t>` - Math text
- Operators: `<m:f>` (fraction), `<m:sup>` (superscript), `<m:sub>` (subscript)

#### Step 2.1: Analyze Math Structure (20 min)

**Tasks**:
1. Extract OMML from Equations.dotx
2. Identify common patterns
3. Map to class structure
4. Determine integration points

**Expected Pattern**:
```xml
<m:oMathPara>
  <m:oMath>
    <m:r>
      <m:t>x</m:t>
    </m:r>
    <m:sup>
      <m:e>
        <m:r><m:t>2</m:t></m:r>
      </m:e>
    </m:sup>
  </m:oMath>
</m:oMathPara>
```

#### Step 2.2: Implement Math Core Classes (40 min)

**Create**:
1. `lib/uniword/math/o_math_para.rb` - Math paragraph
2. `lib/uniword/math/o_math.rb` - Math expression
3. `lib/uniword/math/math_run.rb` - Math run
4. `lib/uniword/math/math_text.rb` - Math text

**Pattern** (Example for OMathPara):
```ruby
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

#### Step 2.3: Integrate Math into Body (20 min)

**Modify**: `lib/uniword/wordprocessingml/body.rb`

**Changes**:
```ruby
attribute :o_math_para, Math::OMathPara, collection: true

xml do
  map_element 'oMathPara', to: :o_math_para,
              namespace: Uniword::Ooxml::Namespaces::MathML
end
```

#### Step 2.4: Test Math Parsing (20 min)

**Validate**:
1. Run full test suite
2. Check Equations.dotx specifically
3. Verify no regressions
4. Confirm 274/274 target

**Expected Improvement**: +2-4 tests (Equations, possibly Bibliography)

## 📈 Success Criteria

### Must Have
- [ ] **274/274 tests passing** (100%)
- [ ] Zero regressions on existing 266 tests
- [ ] 100% model-driven (no `:string` XML content)
- [ ] Pattern 0 compliance (all new classes)
- [ ] MECE architecture maintained

### Should Have  
- [ ] Complete VML parsing (Group, Shape coverage)
- [ ] Complete Math parsing (OMathPara, OMath coverage)
- [ ] Clear documentation of patterns
- [ ] Performance maintained (< 5% slowdown)

### Nice to Have
- [ ] Extended VML support (all shape types)
- [ ] Extended Math support (all operators)
- [ ] Code coverage > 90% on new classes

## 🎯 Timeline Estimates

### Conservative (4 hours)
- VML Analysis: 30 min
- VML Implementation: 90 min
- VML Testing: 30 min
- Math Analysis: 30 min
- Math Implementation: 60 min
- Math Testing: 30 min
- **Total**: 4 hours

### Optimistic (3 hours)
- VML quick patterns: 20 min
- VML rapid implementation: 60 min
- VML quick test: 20 min
- Math quick patterns: 20 min
- Math rapid implementation: 40 min
- Math quick test: 20 min
- **Total**: 3 hours

### Realistic Target
- **3.5 hours** - Account for unexpected issues
- Pattern mastery from Session 2 helps
- Clear path from analysis reduces detours

## 🔍 Risk Mitigation

### Known Risks

1. **VML Complexity**
   - **Risk**: VML has 100+ shape types and attributes
   - **Mitigation**: Focus on patterns in failing tests only
   - **Fallback**: Implement common shapes, defer edge cases

2. **Math Operator Coverage**
   - **Risk**: OMML has 50+ math operators
   - **Mitigation**: Check which operators appear in Equations.dotx
   - **Fallback**: Implement core operators (fraction, super, sub)

3. **Namespace Conflicts**
   - **Risk**: VML/Math namespaces may conflict with existing
   - **Mitigation**: Use explicit namespace declarations
   - **Fallback**: Review all namespace registrations

4. **Integration Points**
   - **Risk**: VML/Math may need integration in multiple places
   - **Mitigation**: Start with Pict and Body integration
   - **Fallback**: Add integration points as needed

### Contingency Plan

**If 274/274 not reached**:
1. Document exact remaining failures
2. Analyze root cause (VML? Math? Other?)
3. Create Phase 5 Session 4 plan if needed
4. Ensure no regressions on 266 baseline

**If time overruns**:
1. Split into Session 3A (VML) and 3B (Math)
2. Target interim milestone (270/274)
3. Continue iteratively to 274

## 📝 Documentation Requirements

### Session 3 Complete Summary
- Overview of VML and Math implementation
- Test results before/after
- Architecture diagrams
- Time taken vs estimates
- Lessons learned

### Memory Bank Update
- Mark Session 3 complete
- Update test counts (274/274)
- Document VML and Math patterns
- Prepare for post-Phase 5 work

### Code Documentation
- Add RDoc comments to new classes
- Document VML shape patterns
- Document Math operator patterns
- Include usage examples

## 🎉 Expected Outcome

**After Session 3**:
- ✅ 274/274 tests (100%)
- ✅ Phase 5 COMPLETE
- ✅ 100% Round-Trip Fidelity for all 61 reference files
- ✅ Complete model-driven architecture
- ✅ Ready for v1.1.0 release

**Victory Conditions**:
1. All StyleSets round-trip perfectly (168/168)
2. All Themes round-trip perfectly (174/174)
3. All Document Elements round-trip perfectly (16/16)
4. All Glossary documents round-trip perfectly (8/8)
5. Zero technical debt
6. Clean, maintainable codebase

---

**Time Estimate**: 3-4 hours
**Complexity**: Medium (clear patterns from Session 2)
**Priority**: HIGH (completes Phase 5)
**Impact**: Achieves 100% round-trip fidelity 🎯

**Ready to Begin**: YES ✅
**Start Document**: `PHASE5_SESSION3_PROMPT.md` (next)