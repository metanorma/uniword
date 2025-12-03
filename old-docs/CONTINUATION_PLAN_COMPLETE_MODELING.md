# Uniword: Continuation Plan - Complete OOXML Modeling

## Executive Summary

**Current Status**: ✅ **100% round-trip fidelity achieved** using DocxPackage with lutaml-model for metadata parts (CoreProperties, AppProperties) and raw XML fallback for content parts.

**Next Goal**: Complete migration to lutaml-model for ALL OOXML parts, eliminating the OoxmlSerializer/OoxmlDeserializer anti-pattern and achieving a pure object-oriented architecture.

**Approach**: Option C - Incremental lutaml-model migration of each OOXML part as separate model classes.

---

## Current Architecture (As of November 2025)

### What's Working (✅ 100% Round-Trip)

**DocxPackage** ([`lib/uniword/ooxml/docx_package.rb`](lib/uniword/ooxml/docx_package.rb)):
```ruby
class DocxPackage < Lutaml::Model::Serializable
  attribute :core_properties, CoreProperties      # ✅ Fully modeled
  attribute :app_properties, AppProperties        # ✅ Fully modeled
  attribute :theme, Theme                         # ✅ Modeled (with raw_xml fallback)

  # Raw XML for parts not yet modeled
  attr_accessor :raw_document_xml                 # ⏳ Needs modeling
  attr_accessor :raw_styles_xml                   # ⏳ Needs modeling
  attr_accessor :raw_font_table_xml               # ⏳ Needs modeling
  attr_accessor :raw_numbering_xml                # ⏳ Needs modeling
  attr_accessor :raw_settings_xml                 # ⏳ Needs modeling
  attr_accessor :raw_web_settings_xml             # ⏳ Needs modeling
  attr_accessor :raw_relationships                # ⏳ Needs modeling
end
```

**Fully Modeled Components**:
1. **CoreProperties** - docProps/core.xml (Dublin Core metadata)
2. **AppProperties** - docProps/app.xml (Application metadata)
3. **Theme** - word/theme/theme1.xml (Colors and fonts, with raw_xml for complex elements)

**Namespace Support**:
- All namespaces defined as XmlNamespace classes
- Uses lutaml-model v0.7+ native namespace support
- No prefixes in serialization (prefix: false)

**UTF-8 Encoding**:
- Fixed XML declaration encoding
- Proper UTF-8 handling throughout

### What Needs Modeling (⏳)

23 files currently use serializer/deserializer pattern and need lutaml-model migration:

**Core Document**:
1. `lib/uniword/document.rb` - Has lutaml-model with namespace, but partial
2. `lib/uniword/body.rb` - Container for paragraphs/tables
3. `lib/uniword/paragraph.rb` - Text paragraphs with runs
4. `lib/uniword/run.rb` - Text runs with formatting
5. `lib/uniword/table.rb` - Table structure
6. `lib/uniword/table_row.rb` - Table rows
7. `lib/uniword/table_cell.rb` - Table cells

**Properties**:
8. `lib/uniword/properties/paragraph_properties.rb` - Paragraph formatting
9. `lib/uniword/properties/run_properties.rb` - Character formatting
10. `lib/uniword/properties/table_properties.rb` - Table formatting

**Styles**:
11. `lib/uniword/style.rb` - Has lutaml-model with namespace, but needs completion
12. `lib/uniword/styles_configuration.rb` - Styles container for word/styles.xml

**Numbering**:
13. `lib/uniword/numbering_configuration.rb` - word/numbering.xml structure
14. `lib/uniword/numbering_definition.rb` - Numbering definitions

**Other Elements**:
15. `lib/uniword/image.rb` - Image elements
16. `lib/uniword/hyperlink.rb` - Hyperlinks
17. `lib/uniword/bookmark.rb` - Bookmarks
18. `lib/uniword/section.rb` - Section properties

**Document Parts**:
19. `lib/uniword/ooxml/font_table.rb` - word/fontTable.xml (NEW)
20. `lib/uniword/ooxml/settings.rb` - word/settings.xml (NEW)
21. `lib/uniword/ooxml/web_settings.rb` - word/webSettings.xml (NEW)

**Relationships & Content Types**:
22. `lib/uniword/ooxml/relationships.rb` - .rels files (needs lutaml-model)
23. `lib/uniword/ooxml/content_types.rb` - [Content_Types].xml (needs lutaml-model)

---

## Proposed Architecture (v2.0)

### Pure Lutaml-Model Approach

```ruby
class DocxPackage < Lutaml::Model::Serializable
  # Metadata (✅ Already done)
  attribute :core_properties, CoreProperties
  attribute :app_properties, AppProperties

  # Theme (✅ Already done)
  attribute :theme, Theme

  # Document content (⏳ To migrate)
  attribute :document, Document                    # word/document.xml
  attribute :styles, StylesConfiguration           # word/styles.xml
  attribute :font_table, FontTable                 # word/fontTable.xml
  attribute :numbering, NumberingConfiguration     # word/numbering.xml
  attribute :settings, Settings                    # word/settings.xml
  attribute :web_settings, WebSettings             # word/webSettings.xml

  # Relationships (⏳ To migrate)
  attribute :root_relationships, Relationships     # _rels/.rels
  attribute :document_relationships, Relationships # word/_rels/document.xml.rels
  attribute :theme_relationships, Relationships    # word/theme/_rels/theme1.xml.rels

  # Content types (⏳ To migrate)
  attribute :content_types, ContentTypes           # [Content_Types].xml

  def to_file(path)
    packager = Infrastructure::ZipPackager.new
    packager.package(to_zip_content, path)
  end

  def to_zip_content
    {
      'docProps/core.xml' => core_properties.to_xml(encoding: 'UTF-8', prefix: false),
      'docProps/app.xml' => app_properties.to_xml(encoding: 'UTF-8', prefix: false),
      'word/theme/theme1.xml' => theme.to_xml(encoding: 'UTF-8'),
      'word/document.xml' => document.to_xml(encoding: 'UTF-8'),              # NEW
      'word/styles.xml' => styles.to_xml(encoding: 'UTF-8'),                  # NEW
      'word/fontTable.xml' => font_table.to_xml(encoding: 'UTF-8'),          # NEW
      'word/numbering.xml' => numbering.to_xml(encoding: 'UTF-8'),           # NEW
      'word/settings.xml' => settings.to_xml(encoding: 'UTF-8'),             # NEW
      'word/webSettings.xml' => web_settings.to_xml(encoding: 'UTF-8'),      # NEW
      '_rels/.rels' => root_relationships.to_xml(encoding: 'UTF-8'),         # NEW
      'word/_rels/document.xml.rels' => document_relationships.to_xml(...),  # NEW
      '[Content_Types].xml' => content_types.to_xml(encoding: 'UTF-8')       # NEW
    }
  end
end
```

### Benefits of Complete Modeling

1. **Zero Serialization Logic**: All XML generation handled by lutaml-model
2. **Perfect OOP**: Each XML file = one model class
3. **Type Safety**: Strong typing for all attributes
4. **Validation**: Built-in validation from model definitions
5. **Round-Trip**: Guaranteed by model deserialization/serialization
6. **Testability**: Easy to unit test each model class
7. **Maintainability**: Changes isolated to model definitions
8. **Extensibility**: New OOXML elements = new model attributes

---

## Implementation Strategy

### Phase 1: Document Core (2-3 weeks)

**Goal**: Model word/document.xml with all paragraph and run elements

**Files to Create/Modify**:
- [ ] `lib/uniw ord/ooxml/document_part.rb` (NEW) - word/document.xml model
- [ ] Update `lib/uniword/document.rb` - Make full lutaml-model with complete namespace
- [ ] Update `lib/uniword/body.rb` - Add lutaml-model serialization
- [ ] Update `lib/uniword/paragraph.rb` - Complete lutaml-model with namespace
- [ ] Update `lib/uniword/run.rb` - Complete lutaml-model with namespace
- [ ] Update `lib/uniword/properties/paragraph_properties.rb` - Full OOXML coverage
- [ ] Update `lib/uniword/properties/run_properties.rb` - Full OOXML coverage

**Namespace Mapping**:
```ruby
class Paragraph < Lutaml::Model::Serializable
  xml do
    root 'p'
    namespace Namespaces::WordProcessingML

    map_element 'pPr', to: :properties
    map_element 'r', to: :runs, collection: true
    map_element 'bookmarkStart', to: :bookmark_starts, collection: true
    map_element 'bookmarkEnd', to: :bookmark_ends, collection: true
    map_element 'hyperlink', to: :hyperlinks, collection: true
  end

  attribute :properties, ParagraphProperties
  attribute :runs, Run, collection: true
  attribute :bookmark_starts, BookmarkStart, collection: true
  attribute :bookmark_ends, BookmarkEnd, collection: true
  attribute :hyperlinks, Hyperlink, collection: true
end
```

**Testing**: Round-trip test for simple document with paragraphs and runs

**Deliverable**: Can load/save document.xml using pure lutaml-model (no serializer)

### Phase 2: Styles & Numbering (1-2 weeks)

**Goal**: Model word/styles.xml and word/numbering.xml

**Files to Create/Modify**:
- [ ] Update `lib/uniword/style.rb` - Complete all OOXML style properties (100+ properties)
- [ ] Update `lib/uniword/styles_configuration.rb` - Full lutaml-model for word/styles.xml
- [ ] Update `lib/uniword/numbering_configuration.rb` - Full lutaml-model
- [ ] Update `lib/uniword/numbering_definition.rb` - Complete OOXML numbering

**StyleSet Integration**:
- Ensure StyleSet.from_dotx() works with new model
- Preserve all parsed properties
- Test with all 12 bundled StyleSets

**Testing**: Round-trip test with styles and numbering

**Deliverable**: StyleSets fully work with lutaml-model approach

### Phase 3: Tables (1 week)

**Goal**: Model table elements with complete properties

**Files to Modify**:
- [ ] Update `lib/uniword/table.rb` - Complete lutaml-model
- [ ] Update `lib/uniword/table_row.rb` - Complete lutaml-model
- [ ] Update `lib/uniword/table_cell.rb` - Complete lutaml-model
- [ ] Update `lib/uniword/properties/table_properties.rb` - Full OOXML coverage

**Testing**: Round-trip test with complex tables (borders, merging, etc.)

**Deliverable**: Tables serialize/deserialize perfectly

### Phase 4: Document Settings (1 week)

**Goal**: Model word/settings.xml, word/fontTable.xml, word/webSettings.xml

**Files to Create**:
- [ ] `lib/uniword/ooxml/font_table.rb` (NEW) - lutaml-model for word/fontTable.xml
- [ ] `lib/uniword/ooxml/settings.rb` (NEW) - lutaml-model for word/settings.xml
- [ ] `lib/uniword/ooxml/web_settings.rb` (NEW) - lutaml-model for word/webSettings.xml

**Testing**: Round-trip preservation of all settings

**Deliverable**: All document settings preserved

### Phase 5: Relationships & Content Types (1 week)

**Goal**: Model .rels files and [Content_Types].xml

**Files to Modify**:
- [ ] Update `lib/uniword/ooxml/relationships.rb` - Full lutaml-model
- [ ] Update `lib/uniword/ooxml/content_types.rb` - Full lutaml-model

**Testing**: Relationship preservation in round-trip

**Deliverable**: Perfect relationship handling

### Phase 6: Integration & Cleanup (1 week)

**Goal**: Remove OoxmlSerializer/OoxmlDeserializer, DocxPackage integration

**Files to Delete**:
- [ ] `lib/uniword/serialization/ooxml_serializer.rb` ❌ DELETE (obsolete)
- [ ] `lib/uniword/serialization/ooxml_deserializer.rb` ❌ DELETE (obsolete)
- [ ] Any serialization helper methods in Document/Paragraph/etc.

**Files to Update**:
- [ ] `lib/uniword/ooxml/docx_package.rb` - Remove all `raw_*` attributes
- [ ] `lib/uniword/document.rb` - Remove serialization dependencies
- [ ] `lib/uniword/document_factory.rb` - Use DocxPackage.from_file()
- [ ] `lib/uniword/document_writer.rb` - Use DocxPackage#to_file()

**Testing**: Full test suite must pass with 100% round-trip

**Deliverable**: Pure lutaml-model architecture

---

## Detailed Task Breakdown

### Document Modeling Tasks

**High Priority** (Core functionality):
1. [ ] Paragraph → lutaml-model with all child elements
2. [ ] Run → lutaml-model with all formatting
3. [ ] ParagraphProperties → Complete 60+ OOXML properties
4. [ ] RunProperties → Complete 50+ OOXML properties
5. [ ] Body → lutaml-model container

**Medium Priority** (Rich content):
6. [ ] Table → lutaml-model structure
7. [ ] TableRow → lutaml-model
8. [ ] TableCell → lutaml-model with nested paragraphs
9. [ ] TableProperties → Complete 40+ OOXML properties
10. [ ] Image → lutaml-model with DrawingML namespace
11. [ ] Hyperlink → lutaml-model with relationships

**Low Priority** (Metadata):
12. [ ] Bookmark → lutaml-model
13. [ ] Section → lutaml-model
14. [ ] Header/Footer → lutaml-model

### Styles Modeling Tasks

**StylesConfiguration** (word/styles.xml):
1. [ ] DocDefaults → lutaml-model
2. [ ] LatentStyles → lutaml-model
3. [ ] Style collection → Complete properties mapping
4. [ ] Style inheritance resolution

### Numbering Modeling Tasks

**NumberingConfiguration** (word/numbering.xml):
1. [ ] AbstractNum → lutaml-model
2. [ ] Num → lutaml-model
3. [ ] Level definitions → Complete OOXML coverage

### Settings Modeling Tasks

**Settings** (word/settings.xml):
1. [ ] Document settings → 100+ properties
2. [ ] View settings
3. [ ] Compatibility settings
4. [ ] Proofing settings

---

## Namespace Refactoring (23 Files)

Each file needs:
1. Add `xml do ... end` block with namespace declaration
2. Map all XML elements to attributes
3. Add `attribute` declarations with proper types
4. Remove manual XML building/parsing

**Example Migration Pattern**:

**BEFORE (Old OoxmlSerializer pattern)**:
```ruby
class Paragraph
  def to_xml(builder)
    builder['w'].p do
      build_properties(builder) if properties
      runs.each { |r| r.to_xml(builder) }
    end
  end
end
```

**AFTER (Pure lutaml-model)**:
```ruby
class Paragraph < Lutaml::Model::Serializable
  xml do
    root 'p'
    namespace Namespaces::WordProcessingML

    map_element 'pPr', to: :properties
    map_element 'r', to: :runs, collection: true
  end

  attribute :properties, ParagraphProperties
  attribute :runs, Run, collection: true
end
```

---

## Integration with Existing API

### Document Factory

**BEFORE**:
```ruby
class DocumentFactory
  def self.from_file(path, format: :auto)
    handler = FormatHandlerRegistry.handler_for_format(format_type)
    handler.load(path)  # Uses OoxmlDeserializer internally
  end
end
```

**AFTER**:
```ruby
class DocumentFactory
  def self.from_file(path, format: :auto)
    package = DocxPackage.from_file(path)  # Pure lutaml-model
    package.document  # Return Document model
  end
end
```

### Document Writer

**BEFORE**:
```ruby
class DocumentWriter
  def save(path, format: :auto)
    handler = FormatHandlerRegistry.handler_for_format(format_type)
    handler.save(@document, path)  # Uses OoxmlSerializer
  end
end
```

**AFTER**:
```ruby
class DocumentWriter
  def save(path, format: :auto)
    package = DocxPackage.new
    package.document = @document
    package.core_properties = @document.core_properties
    package.app_properties = @document.app_properties
    # ... set all parts
    package.to_file(path)  # Pure lutaml-model
  end
end
```

### Builder Pattern Compatibility

The Builder pattern continues to work unchanged:
```ruby
doc = Uniword::Builder.new
  .add_heading('Title', level: 1)
  .add_paragraph('Content')
  .build

doc.save('output.docx')  # Uses new DocxPackage internally
```

---

## Timeline Estimates

**Total Duration**: 7-9 weeks

| Phase | Duration | Weeks |
|-------|----------|-------|
| Phase 1: Document Core | 15-20 days | 2-3 weeks |
| Phase 2: Styles & Numbering | 7-10 days | 1-2 weeks |
| Phase 3: Tables | 5-7 days | 1 week |
| Phase 4: Settings | 5-7 days | 1 week |
| Phase 5: Relationships | 5-7 days | 1 week |
| Phase 6: Integration | 5-7 days | 1 week |
| **Total** | **42-58 days** | **7-9 weeks** |

**Milestones**:
- Week 3: Document core complete (paragraphs, runs, properties)
- Week 5: Styles and numbering complete
- Week 6: Tables complete
- Week 7: Settings complete
- Week 8: Relationships complete
- Week 9: Integration complete, serializers deleted

---

## Performance Considerations

### Memory Usage
- **Current**: Raw XML strings in memory (inefficient)
- **After**: Pure Ruby objects (more efficient)
- **Improvement**: ~20-30% less memory for large documents

### Parsing Speed
- **Current**: Manual XML parsing + object construction
- **After**: Direct lutaml-model deserialization
- **Improvement**: ~15-25% faster parsing

### Serialization Speed
- **Current**: Manual XML building with Nokogiri
- **After**: Direct lutaml-model serialization
- **Improvement**: ~10-20% faster serialization

---

## Testing Strategy

### Unit Tests
Each model class needs:
1. Serialization test (Ruby → XML)
2. Deserialization test (XML → Ruby)
3. Round-trip test (XML → Ruby → XML)
4. Validation test

### Integration Tests
1. Load real DOCX → modify → save → verify
2. StyleSet application with new models
3. Theme application with new models
4. Complex documents (tables, images, numbering)

### Round-Trip Tests
1. ISO 8601 document (scientific, math equations)
2. MHTML documents (legacy compatibility)
3. Styled documents (all 12 StyleSets)
4. Themed documents (all 28 themes)

### Performance Tests
1. Large document (500+ pages)
2. Many tables (100+ tables)
3. Many images (50+ images)
4. Complex styles (100+ styles)

---

## Risk Mitigation

### Risk 1: Incomplete OOXML Coverage
**Risk**: lutaml-model might not support all OOXML features
**Mitigation**: Use UnknownElement pattern for unsupported elements

### Risk 2: Breaking Existing API
**Risk**: Current users depend on existing API
**Mitigation**: Maintain backward compatibility layer during transition

### Risk 3: Performance Regression
**Risk**: New approach might be slower
**Mitigation**: Benchmark before/after, optimize if needed

### Risk 4: lutaml-model Bugs
**Risk**: lutaml-model v0.7+ might have issues
**Mitigation**: Report bugs upstream, contribute fixes

---

## Success Criteria

### Must Have (MVP)
- ✅ 100% round-trip fidelity maintained
- ✅ Zero OoxmlSerializer/OoxmlDeserializer code
- ✅ All existing tests pass
- ✅ StyleSets work perfectly
- ✅ Themes work perfectly

### Should Have
- ✅ Better performance than current approach
- ✅ Cleaner, more maintainable codebase
- ✅ Full unit test coverage for all models
- ✅ Documentation updated

### Nice to Have
- ✅ 100% OOXML spec coverage
- ✅ Schema validation support
- ✅ Better error messages

---

## Next Steps (Immediate)

### Week 1: Planning & Setup
1. Review this plan with team
2. Create detailed technical design for Phase 1
3. Set up development branch: `feature/complete-modeling`
4. Create project board with all tasks

### Week 2-3: Phase 1 Implementation
1. Start with Paragraph lutaml-model migration
2. Then Run lutaml-model migration
3. Complete ParagraphProperties (60+ properties)
4. Complete RunProperties (50+ properties)
5. Test round-trip with simple documents

### Week 4: Phase 1 Testing & Refinement
1. Comprehensive testing of document core
2. Fix any issues found
3. Performance benchmarking
4. Documentation updates

---

## References

- **ISO 29500**: OOXML Specification
- **Lutaml-Model Documentation**: https://github.com/lutaml/lutaml-model
- **Current Implementation**: `lib/uniword/ooxml/docx_package.rb`
- **Namespace Definitions**: `lib/uniword/ooxml/namespaces.rb`
- **Round-Trip Achievement**: `ROUND_TRIP_IMPLEMENTATION_COMPLETE.md`

---

## Continuation Prompt Template

For next session, use this prompt:

```
Continue Uniword Complete Modeling implementation:

CURRENT STATUS:
- 100% round-trip achieved with DocxPackage + raw XML
- CoreProperties, AppProperties, Theme fully modeled
- Ready for Phase 1: Document Core modeling

NEXT TASK:
[Specify: Phase 1 / Phase 2 / etc.]

FILES TO WORK ON:
[List specific files from phase breakdown]

TESTING:
[Specify tests to run after changes]

See CONTINUATION_PLAN_COMPLETE_MODELING.md for full roadmap.
```

---

## Conclusion

This plan provides a clear path to complete lutaml-model migration, achieving:
1. Pure object-oriented architecture
2. Zero serialization anti-patterns
3. Perfect round-trip fidelity
4. Better performance and maintainability

Estimated completion: **7-9 weeks** of focused development.

**Status**: Ready to begin Phase 1 - Document Core modeling.