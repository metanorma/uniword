# TODO: Round-Trip Fidelity - Critical Path

## Status: HIGH PRIORITY - Master Tracking Issue

## Overview

Round-trip tests are the **most critical** test category because they ensure that:
1. Documents can be saved and loaded correctly
2. Content is preserved through serialization cycles
3. XML structure is semantically equivalent (not necessarily byte-identical)

## Current Round-Trip Test Failures

### By Category

| Category | Test File | Count | Status |
|----------|-----------|-------|--------|
| Document | `document_roundtrip_spec.rb` | 4 | FAILED |
| Theme | `theme_roundtrip_spec.rb` | 1 | FAILED |
| Styles | `style_roundtrip_spec.rb` | ~8 | FAILED |
| Package | `docx_package_spec.rb` | ~8 | FAILED |
| Core Props | `core_properties_spec.rb` | 2 | FAILED |
| App Props | `app_properties_spec.rb` | 2 | FAILED |

### Total: ~25 round-trip failures

## Root Causes

### 1. Namespace Handling (lutaml-model issue)
- `dc:title` not parsed correctly
- Namespace prefix `w:` not declared at document level during serialization

### 2. Content Extraction (ElementSerializer issue)
- Text content not extracted from runs
- Property values not serialized

### 3. YAML Schema Mismatch (StyleSet issue)
- Flat YAML structure doesn't match nested OOXML objects
- Type conversion errors during deserialization

### 4. MHTML Transformation (missing implementation)
- HTML content not transformed to OOXML paragraphs
- Format conversion produces empty documents

## Dependency Graph

```
Round-Trip Tests
    │
    ├───[1] Namespace Handling ─── lutaml-model team (external)
    │
    ├───[2] Content Extraction ─── ElementSerializer fix (internal)
    │
    ├───[3] YAML Schema ─── StyleSet restructure (internal)
    │
    └───[4] MHTML Transform ─── New implementation (internal)
```

## Fix Order (by dependency)

### Phase 1: External Dependencies (BLOCKING)
**Issue**: lutaml-model namespace handling for multi-namespace XML
**Owner**: lutaml-model team
**TODO**: `TODO/lutaml-model-namespace-proposal.md`
**ETA**: 2026-03-20

### Phase 2: Internal Fixes (PARALLEL after Phase 1)

#### 2a: ElementSerializer Content Extraction
**TODO**: `TODO/element-serializer-content-extraction.md`
**ETA**: 2026-03-19
**Alternative**: Deprecate ElementSerializer, use native lutaml-model serialization

#### 2b: StyleSet YAML Restructure
**TODO**: `TODO/styleset-yaml-restructure.md`
**ETA**: 2026-03-20

#### 2c: MHTML to DOCX Transformation
**TODO**: `TODO/mhtml-to-docx-transformation.md`
**ETA**: 2026-03-21

## Success Criteria

A round-trip test passes when:

1. **Load**: Document loads from file without error
2. **Serialize**: Document serializes to XML without error
3. **Load Again**: Serialized document loads back
4. **Compare**: Content is semantically equivalent
   - Same paragraphs, runs, text
   - Same table structures
   - Same style references (even if XML differs slightly)
5. **Serialize Again**: Second serialization matches first

## Test Template

```ruby
RSpec.shared_examples 'round-trip fidelity' do |format, factory_method|
  it 'preserves content through round-trip' do
    # Create document with content
    doc = send(factory_method)

    # Serialize
    xml = doc.to_xml

    # Deserialize
    restored = described_class.from_xml(xml)

    # Verify semantic equivalence
    expect(restored.text).to eq(doc.text)
    expect(restored.paragraphs.count).to eq(doc.paragraphs.count)

    # Serialize again
    xml2 = restored.to_xml

    # XML should be equivalent (stable)
    expect(xml2).to be_xml_equivalent_to(xml)
  end
end
```

## Metrics

### Current State
- Total round-trip tests: ~25
- Passing: 0
- Failing: 25

### Target State
- Total round-trip tests: ~25
- Passing: 25
- Failing: 0

### Progress Tracking

| Date | Passing | Failing | Notes |
|------|---------|---------|-------|
| 2026-03-16 | 0 | 25 | Baseline |
| | | | |
| | | | |

## Daily Standup

During daily development:
1. Run round-trip tests FIRST before other tests
2. Any new feature must include a round-trip test
3. Round-trip test failures block PRs

## Commands

```bash
# Run all round-trip tests
bundle exec rspec spec --format documentation -e "round.?trip"

# Run specific round-trip test
bundle exec rspec spec/uniword/document_roundtrip_spec.rb

# Check round-trip coverage
bundle exec rspec --format documentation -e "round.?trip" 2>&1 | grep "0 failures"
```
