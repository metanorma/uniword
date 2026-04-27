# 18: Add tests for 26 untested source directories (663 files)

**Priority:** P1
**Effort:** Large (ongoing)
**File:** `spec/uniword/`

## Problem

26 source directories containing 663 source files have zero dedicated spec
files. These represent the majority of generated OOXML model classes and
several hand-written modules.

## Untested directories (by size)

| Source directory | Files | Description |
|-----------------|-------|-------------|
| `spreadsheetml/` | 105 | Spreadsheet ML elements |
| `chart/` | 72 | Chart elements |
| `presentationml/` | 49 | Presentation ML elements |
| `customxml/` | 35 | Custom XML markup |
| `vml_office/` | 29 | VML for Office |
| `wp_drawing/` | 29 | WordProcessing Drawing |
| `bibliography/` | 28 | Bibliography/citations |
| `wordprocessingml_2010/` | 25 | Word 2010 extensions |
| `vml/` | 24 | VML graphics |
| `document_properties/` | 20 | Core/app properties |
| `wordprocessingml_2013/` | 20 | Word 2013 extensions |
| `glossary/` | 19 | Glossary document parts |
| `office/` | 40 | Office base elements |
| `picture/` | 11 | Picture elements |
| `theme/` + `themes/` | 9 | Theme elements |
| `content_types/` | 3 | Content types |
| `warnings/` | 3 | Warning classes |
| `document_variables/` | 10 | Document variables |
| `shared_types/` | 15 | Shared type definitions |
| `wordprocessingml_2016/` | 15 | Word 2016 extensions |
| `word2010_ext/` | 1 | Word 2010 extension |
| `vml_word/` | 4 | VML for Word |
| `configuration/` | 1 | Configuration |
| `schema/` | 2 | Schema management |
| `serialization/` | 1 | Serialization |
| (top-level files) | ~40 | header, footer, image, section, etc. |

## Approach

**Phase 1 — Smoke tests for generated model classes** (highest value, lowest
effort). Create a shared example that verifies:
- Class can be instantiated
- Attributes are accessible
- `from_xml` / `to_xml` round-trips
- Namespace is correctly set

```ruby
# spec/support/shared_examples/serializable_model.rb
RSpec.shared_examples "a serializable OOXML model" do
  it { is_expected.to respond_to(:to_xml) }
  it { is_expected.to respond_to(:valid?) }

  it "round-trips through XML" do
    xml = described_class.new.to_xml
    expect { described_class.from_xml(xml) }.not_to raise_error
  end
end
```

Then create one spec file per namespace directory that iterates over all
classes in the directory:

```ruby
# spec/uniword/bibliography/models_spec.rb
require "spec_helper"

%w[
  Bibliography Sources Source
].each do |class_name|
  klass = "Uniword::Bibliography::#{class_name}".constantize
  describe klass do
    it_behaves_like "a serializable OOXML model"
  end
end
```

**Phase 2 — API tests for hand-written modules.** Focus on top-level files
with real logic: `html_importer.rb`, `streaming_parser.rb`, `configuration.rb`,
`image.rb`, `section.rb`, etc.

**Phase 3 — Integration tests for extension namespaces.** Test that
Word 2010/2013/2016 extension elements correctly round-trip in actual
documents.

## Verification

```bash
# After Phase 1, test count should increase significantly
bundle exec rspec --format progress
```
