# 03: Add smoke tests for 24 untested source directories (558 files)

**Priority:** P1
**Effort:** Large (~4 hours)
**File:** `spec/uniword/smoke/`

## Problem

24 source directories containing 558 Ruby files have zero dedicated spec files.
The ratio is 1314 source files : 159 spec files (8:1).

The shared example `"a serializable element"` (to_xml + parseable XML) and the
`"a namespaced OOXML element"` pattern can cover most generated model classes
with minimal per-directory effort.

## Untested Directories

| Directory | Files | Namespace |
|-----------|-------|-----------|
| `spreadsheetml/` | 105 | Uniword::Spreadsheetml |
| `chart/` | 72 | Uniword::Chart |
| `presentationml/` | 49 | Uniword::Presentationml |
| `office/` | 40 | Uniword::Office |
| `customxml/` | 35 | Uniword::Customxml |
| `wp_drawing/` | 29 | Uniword::WpDrawing |
| `vml_office/` | 29 | Uniword::VmlOffice |
| `bibliography/` | 28 | Uniword::Bibliography |
| `wordprocessingml_2010/` | 25 | Uniword::Wordprocessingml2010 |
| `vml/` | 24 | Uniword::Vml |
| `document_properties/` | 20 | Uniword::DocumentProperties |
| `wordprocessingml_2013/` | 20 | Uniword::Wordprocessingml2013 |
| `glossary/` | 19 | Uniword::Glossary |
| `shared_types/` | 15 | Uniword::SharedTypes |
| `wordprocessingml_2016/` | 15 | Uniword::Wordprocessingml2016 |
| `document_variables/` | 10 | Uniword::DocumentVariables |
| `picture/` | 11 | Uniword::Picture |
| `theme/` | 6 | Uniword::Theme |
| `content_types/` | 3 | Uniword::ContentTypes |
| `warnings/` | 3 | Uniword::Warnings |
| `vml_word/` | 4 | Uniword::VmlWord |
| `configuration/` | 1 | Uniword::Configuration |
| `schema/` | 2 | Uniword::Schema |
| `serialization/` | 1 | Uniword::Serialization |

## Approach

Create one spec file per directory that discovers and tests all classes:

```ruby
# spec/uniword/smoke/chart_models_spec.rb
RSpec.describe "Chart models" do
  # Autoload triggers constant resolution
  %w[Chart PlotArea Series Axis Legend].each do |name|
    describe "Uniword::Chart::#{name}" do
      subject { "Uniword::Chart::#{name}".constantize.new }
      it_behaves_like "a serializable element"
    end
  end
end
```

For directories where we know specific class names, enumerate them. For
directories with many generated classes, use `autoload` introspection to
discover class names automatically.

Target: increase from 4508 to ~5100+ examples.

## Verification

```bash
bundle exec rspec spec/uniword/smoke/ --format progress
```
