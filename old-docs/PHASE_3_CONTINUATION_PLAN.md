# Phase 3: Integration and Testing - Continuation Plan

**Updated**: November 28, 2024  
**Status**: Architecture Revised - Direct v2.0 Approach  
**Critical Decision**: No backward compatibility needed (gem not released)  

## Architecture Change ⚡

### OLD Approach (Discarded)
- V1 classes with rich API
- V2 generated classes for serialization  
- Adapter pattern to convert between them
- **Problem**: Unnecessary complexity, dual maintenance

### NEW Approach (Correct) ✅
- **DELETE v1.x code** (move to `archive/v1/`)
- **Generated v2.0 classes ARE the API**
- Add convenience methods directly to generated classes
- **Result**: Single source of truth, schema-driven, clean

## Revised Task Breakdown

### Task 1.1 REVISED: Direct Integration (4 hours)

**Goal**: Make generated classes the primary API with rich Ruby methods

#### 1.1.1: Archive v1.x Code (30 min)
```bash
mkdir -p archive/v1
mv lib/uniword/document.rb archive/v1/
mv lib/uniword/body.rb archive/v1/
mv lib/uniword/paragraph.rb archive/v1/
mv lib/uniword/run.rb archive/v1/
mv lib/uniword/properties/ archive/v1/
# ... etc for all v1 classes
```

#### 1.1.2: Delete Adapters (10 min)
```bash
rm -rf lib/uniword/v2/
```

#### 1.1.3: Extend Generated Classes (3 hours)

**Create class extensions** that add convenience methods to generated classes:

`lib/uniword/extensions/document_extensions.rb`:
```ruby
module Uniword
  module Generated
    module Wordprocessingml
      class DocumentRoot
        # Add convenience methods
        def add_paragraph(text = nil, **options)
          para = Paragraph.new
          para.runs << Run.new(text: text) if text
          # Apply options...
          body.paragraphs << para
          para
        end
        
        def save(path)
          writer = Uniword::DocumentWriter.new(self)
          writer.save(path)
        end
      end
    end
  end
end
```

**Apply same pattern to**:
- `Body` - add `add_paragraph()`, `add_table()`
- `Paragraph` - add `add_text()`, `add_run()`, `bold?`, `text()`
- `Run` - add `bold?`, `italic?`, text accessors
- `ParagraphProperties` - add `align()`, fluent setters
- `RunProperties` - add fluent setters

#### 1.1.4: Update Public API (30 min)

Make `Generated::Wordprocessingml::DocumentRoot` available as `Uniword::Document`:

`lib/uniword.rb`:
```ruby
module Uniword
  # Re-export generated classes as primary API
  Document = Generated::Wordprocessingml::DocumentRoot
  Paragraph = Generated::Wordprocessingml::Paragraph
  Run = Generated::Wordprocessingml::Run
  # etc...
end
```

**Result**: `Uniword::Document.new` creates a generated class instance!

### Task 1.2: Serialization (MOSTLY DONE!) (2 hours)

**Good news**: Generated classes already handle serialization via lutaml-model!

#### 1.2.1: Verify Serialization (1 hour)
- Test `document.to_xml()` produces valid OOXML
- Test all 22 namespaces serialize correctly
- Verify namespace prefixes and structure

#### 1.2.2: Add Missing Elements (1 hour)
- Ensure all critical elements have generated classes
- Add any missing convenience methods for serialization

### Task 1.3: Deserialization (MOSTLY DONE!) (2 hours)

**Good news**: Generated classes already handle deserialization via lutaml-model!

#### 1.3.1: Verify Deserialization (1 hour)
- Test `DocumentRoot.from_xml(xml)` parses correctly
- Test all 22 namespaces deserialize correctly
- Verify attribute mapping

#### 1.3.2: Add Missing Parsers (1 hour)
- Handle edge cases in XML parsing
- Add validation for required attributes

### Task 1.4: Format Handlers (2 hours)

Update handlers to use generated classes directly.

#### 1.4.1: Update DocxHandler (1 hour)

`lib/uniword/formats/docx_handler.rb`:
```ruby
def self.load(path)
  xml = extract_document_xml(path)
  Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
end

def self.save(document, path)
  xml = document.to_xml  # Generated class handles it!
  package_to_zip(xml, path)
end
```

#### 1.4.2: Update Other Handlers (1 hour)
- Update `MhtmlHandler`
- Update `DocumentFactory`
- Update `DocumentWriter`

### Task 2: Testing (12 hours)

#### 2.1: Unit Tests (4 hours)
- Test generated classes with extensions
- Test serialization for each namespace
- Test deserialization for each namespace
- Test convenience methods

#### 2.2: Integration Tests (4 hours)
- Create document → Save → Load → Compare
- Apply properties → Round-trip
- Complex documents with tables, images, etc.

#### 2.3: Round-Trip Tests (2 hours)
- Perfect fidelity for real documents
- Semantic XML comparison (Canon gem)
- No data loss

#### 2.4: Performance Tests (2 hours)
- Meet all benchmarks (< 500ms for complex docs)
- Memory profiling
- Lazy loading verification

### Task 3: Documentation (6 hours)

#### 3.1: Update README.adoc (2 hours)
- Remove v1 examples
- Add v2 generated class examples
- Document new API with convenience methods

#### 3.2: API Documentation (2 hours)
- YARD docs for generated classes + extensions
- Usage examples
- Migration guide (none needed - new gem)

#### 3.3: Move Old Docs (1 hour)
```bash
mv docs/v2.0/TASK_1_1_INTEGRATION_STATUS.md old-docs/
mv docs/NAMESPACE_*.md old-docs/
# Move any temporary implementation docs
```

#### 3.4: CHANGELOG.md (1 hour)
- Document v2.0.0 architecture
- Highlight schema-driven approach
- List all 760 elements across 22 namespaces

## Compressed Timeline (Total: 26 hours)

| Task | Duration | Description |
|------|----------|-------------|
| 1.1 | 4h | Archive v1, extend generated classes, update API |
| 1.2 | 2h | Verify serialization (mostly done) |
| 1.3 | 2h | Verify deserialization (mostly done) |
| 1.4 | 2h | Update format handlers |
| 2.1 | 4h | Unit tests |
| 2.2 | 4h | Integration tests |
| 2.3 | 2h | Round-trip tests |
| 2.4 | 2h | Performance tests |
| 3.1-3.4 | 6h | Documentation |
| **Total** | **26h** | **~3-4 days compressed** |

## Architecture Benefits (Revised)

### 1. Single Source of Truth ✅
- Generated classes ARE the model
- No duplication between v1/v2
- Schema changes automatically propagate

### 2. Schema-Driven All The Way ✅
- Classes generated from YAML schemas
- XML serialization via lutaml-model
- 100% OOXML coverage (760 elements)

### 3. Clean, Extensible ✅
- Extensions add convenience methods
- Core model stays generated (don't modify generated code)
- Easy to regenerate when schema changes

### 4. Simpler Maintenance ✅
- One codebase, not two
- No adapter complexity
- Clear separation: generated vs. extensions

## Critical Files to Update

### Delete/Archive
- [ ] `lib/uniword/document.rb` → `archive/v1/`
- [ ] `lib/uniword/body.rb` → `archive/v1/`
- [ ] `lib/uniword/paragraph.rb` → `archive/v1/`
- [ ] `lib/uniword/run.rb` → `archive/v1/`
- [ ] `lib/uniword/properties/` → `archive/v1/`
- [ ] `lib/uniword/v2/*_adapter.rb` → DELETE (not needed)

### Create New
- [ ] `lib/uniword/extensions/document_extensions.rb`
- [ ] `lib/uniword/extensions/paragraph_extensions.rb`
- [ ] `lib/uniword/extensions/run_extensions.rb`
- [ ] `lib/uniword/extensions/property_extensions.rb`

### Update Existing
- [ ] `lib/uniword.rb` - Re-export generated classes
- [ ] `lib/uniword/formats/docx_handler.rb` - Use generated classes
- [ ] `lib/uniword/document_factory.rb` - Use generated classes
- [ ] `lib/uniword/document_writer.rb` - Use generated classes

## Success Criteria

- [ ] v1 code archived (no backward compat)
- [ ] Generated classes are primary API
- [ ] Convenience methods added via extensions
- [ ] All serialization working (22 namespaces)
- [ ] All deserialization working (22 namespaces)
- [ ] Round-trip perfect fidelity
- [ ] Tests passing (unit + integration + round-trip)
- [ ] Performance targets met
- [ ] Documentation complete
- [ ] Ready for v2.0.0 release

## Next Session Prompt

```markdown
Continue Phase 3 implementation:

1. FIRST: Archive v1 code to archive/v1/ and delete adapters
2. Create extension modules for generated classes
3. Add rich API methods (add_paragraph, add_text, bold?, etc.)
4. Update lib/uniword.rb to re-export generated classes
5. Update format handlers to use generated classes directly
6. Write comprehensive tests
7. Update documentation

Remember: Generated classes ARE the API. No v1/v2 split. Clean and simple.
```

---

*This plan reflects the architectural decision to use generated classes directly, eliminating unnecessary complexity while maintaining a rich, user-friendly API.*