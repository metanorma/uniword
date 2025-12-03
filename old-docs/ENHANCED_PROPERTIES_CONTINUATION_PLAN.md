# Enhanced Properties - Round-Trip Implementation Plan

## Current Status (v1.0.0)

### ✅ Completed - Phase 1: Enhanced Properties XML Serialization
- **Status**: 22/22 tests passing (100%)
- **File**: `spec/uniword/enhanced_properties_xml_spec.rb`
- **Achievement**: All enhanced properties serialize correctly to XML with proper namespace prefixes

**What Works:**
- Run properties: character_spacing, kerning, position, text_expansion, emphasis_mark, language, shading
- Paragraph properties: borders, shading, tab_stops
- Boolean text effects: outline, shadow, emboss, imprint
- Namespace prefixes on attributes: `w:val`, `w:color`, `w:pos`, etc.
- Collection mutations properly tracked and serialized

**Implementation Files:**
- [`lib/uniword/run.rb`](lib/uniword/run.rb:661) - Added `set_shading()` method
- [`lib/uniword/properties/simple_val_properties.rb`](lib/uniword/properties/simple_val_properties.rb) - Wrapper classes for value types
- [`lib/uniword/properties/tab_stop.rb`](lib/uniword/properties/tab_stop.rb) - Tab stop models
- [`lib/uniword/properties/border.rb`](lib/uniword/properties/border.rb) - Border models
- [`lib/uniword/properties/shading.rb`](lib/uniword/properties/shading.rb) - Shading models
- [`lib/uniword/ooxml/namespaces.rb`](lib/uniword/ooxml/namespaces.rb:15) - Updated to `attribute_form_default: :qualified`

## 🎯 Next Phase: Round-Trip Preservation

### Goal
Ensure that documents with enhanced properties can be:
1. Loaded from DOCX
2. Preserved through modifications
3. Saved back to DOCX
4. Re-loaded with identical properties

### Phase 2: Deserialization (Parsing)

**Objective**: Parse enhanced properties from XML when loading DOCX files

**Tasks:**
1. **Update Deserializers**
   - [ ] `lib/uniword/serialization/ooxml_deserializer.rb` - Parse enhanced run properties
   - [ ] Parse enhanced paragraph properties
   - [ ] Parse tab stops from XML
   - [ ] Parse borders from XML
   - [ ] Parse shading from XML

2. **Test Deserialization**
   - [ ] Create test fixtures with enhanced properties
   - [ ] Test loading documents with character spacing
   - [ ] Test loading documents with kerning
   - [ ] Test loading documents with tab stops
   - [ ] Test loading documents with borders
   - [ ] Test loading documents with shading

3. **Integration Tests**
   - [ ] Test that properties survive load → save cycle
   - [ ] Verify namespace prefixes preserved
   - [ ] Verify attribute values preserved

### Phase 3: Round-Trip Spec

**Objective**: Complete round-trip preservation tests

**Tasks:**
1. **Create Round-Trip Test Suite**
   - [ ] `spec/uniword/enhanced_properties_roundtrip_spec.rb`
   - [ ] Test each enhanced property individually
   - [ ] Test combinations of properties
   - [ ] Test with real Word documents

2. **Validation**
   - [ ] Load → Save → Load cycle produces identical results
   - [ ] XML comparison using Canon gem
   - [ ] Semantic equivalence verification

## Implementation Architecture

### Serialization Flow (✅ Complete)
```
Model → OoxmlSerializer → XML with qualified attributes
```

### Deserialization Flow (🚧 Next)
```
XML → OoxmlDeserializer → Model
```

### Round-Trip Flow (🎯 Goal)
```
DOCX → Load → Model → Modify → Save → DOCX
       ↓                                 ↓
    Parse enhanced properties    Serialize enhanced properties
       ↓                                 ↓
    Identical semantic values preserved
```

## Key Architectural Principles

### 1. Object-Oriented Design
- Each property type has its own model class
- Wrapper classes for OOXML value types
- Clear separation between model and serialization

### 2. MECE (Mutually Exclusive, Collectively Exhaustive)
- Each property defined in exactly one place
- No overlap between property types
- Complete coverage of OOXML specification

### 3. Separation of Concerns
- Models: Pure data structures (lutaml-model)
- Serializers: XML generation logic
- Deserializers: XML parsing logic
- Handlers: Format-specific operations

### 4. Extensibility
- Open/Closed Principle: New properties can be added without modifying existing code
- Registry pattern for element types
- Plugin architecture for format handlers

## Testing Strategy

### Unit Tests
- ✅ Each wrapper class serialization
- 🚧 Each wrapper class deserialization
- 🚧 Property preservation in models

### Integration Tests
- ✅ Complex property combinations serialization
- 🚧 Round-trip with actual DOCX files
- 🚧 Semantic equivalence validation

### Regression Tests
- 🚧 Existing tests must still pass
- 🚧 Enhanced properties don't break basic functionality

## Dependencies

### Critical
- `lutaml-model ~> 0.7` - With qualified attribute support ✅
- `nokogiri ~> 1.15` - XML parsing
- `rubyzip ~> 2.3` - ZIP handling

### Testing
- `rspec` - Test framework
- `canon` - XML semantic comparison
- `vcr` - Request recording (if needed)

## File Organization

### Production Code
```
lib/uniword/
├── properties/           # Property models (✅ Complete)
│   ├── simple_val_properties.rb
│   ├── tab_stop.rb
│   ├── border.rb
│   └── shading.rb
├── serialization/        # Serialization layer (🚧 Needs work)
│   ├── ooxml_serializer.rb      (✅ Complete)
│   └── ooxml_deserializer.rb    (🚧 Needs enhanced properties support)
└── ooxml/
    └── namespaces.rb     # Namespace configuration (✅ Complete)
```

### Test Files
```
spec/uniword/
├── enhanced_properties_xml_spec.rb        (✅ Complete - 22/22)
├── enhanced_properties_roundtrip_spec.rb  (🚧 To be created)
└── fixtures/
    └── enhanced_properties/               (🚧 To be created)
        ├── character_spacing.docx
        ├── borders.docx
        └── tab_stops.docx
```

## Performance Targets

- Simple document with enhanced properties: < 100ms load + save
- Complex document (50 pages with properties): < 1s load + save
- Memory footprint: < 50MB for typical documents

## Known Issues & Blockers

### Resolved ✅
1. ~~Attribute namespace prefixes~~ - Fixed by lutaml-model v0.7+
2. ~~Collection mutation tracking~~ - Fixed by lutaml-model
3. ~~Missing Run.set_shading() method~~ - Implemented

### Current Blockers
None! Ready to proceed with deserialization implementation.

## Timeline Estimate

- **Phase 2 (Deserialization)**: 4-6 hours
  - Implement parsing logic: 2-3 hours
  - Create test fixtures: 1 hour
  - Test and debug: 1-2 hours

- **Phase 3 (Round-Trip)**: 2-3 hours
  - Create round-trip test suite: 1 hour
  - Integration testing: 1-2 hours

**Total Estimate**: 6-9 hours to complete full round-trip support

## Success Criteria

1. ✅ All enhanced properties serialize to correct XML (22/22 tests)
2. 🎯 All enhanced properties deserialize from XML correctly
3. 🎯 Round-trip preservation: Load → Save → Load produces identical results
4. 🎯 No regression in existing functionality
5. 🎯 Performance targets met
6. 🎯 Documentation updated

## Next Session Priority

**IMMEDIATE**: Implement deserialization for enhanced properties in `ooxml_deserializer.rb`

**Focus Areas:**
1. Parse run properties from `<w:rPr>` elements
2. Parse paragraph properties from `<w:pPr>` elements  
3. Create wrapper object instances from XML attributes
4. Test with real DOCX files containing these properties