# Plan: Fix Format Converter and Resource Specs

## Problem

Tests fail related to format conversion, document writing, and resource extraction.

## Failing Tests

### format_converter_spec.rb (3 failures)
- `ConversionResult when conversion fails reports failure` - line 355
- `ConversionResult when conversion fails includes error message` - line 359
- `ConversionResult when conversion fails shows failure in summary` - line 363

### document_writer_spec.rb (1 failure)
- `performs full write-read cycle for DOCX` - line 152

### resource_roundtrip_spec.rb (1 failure)
- `extracts styleset from DOCX` - line 172

## Root Cause Analysis

### format_converter_spec.rb (3 failures)

**Bug in test**: The `context 'when conversion fails'` is inside `describe 'ConversionResult'` but uses `described_class.new(...)` which resolves to `Uniword::FormatConverter.new(...)` instead of `Uniword::FormatConverter::ConversionResult.new(...)`.

Error:
```
NoMethodError: undefined method `success?' for an instance of Uniword::FormatConverter
```

The test at line 343-352:
```ruby
context 'when conversion fails' do
  subject(:failed_result) do
    described_class.new(  # BUG: described_class is FormatConverter, not ConversionResult!
      source: 'input.docx',
      ...
    )
  end
end
```

**Fix**: Change `described_class.new` to `Uniword::FormatConverter::ConversionResult.new`

### document_writer_spec.rb:152

**API mismatch**: The test expects `DocumentFactory.from_file` to return a `DocxPackage`:
```ruby
loaded_doc = Uniword::DocumentFactory.from_file(temp_file.path)
expect(loaded_doc).to be_a(Uniword::Ooxml::DocxPackage)
```

But `DocumentFactory.from_file` returns `DocumentRoot` for DOCX files (for convenience):
```ruby
when :docx
  package = Ooxml::DocxPackage.from_file(path)
  doc = package.respond_to?(:document) ? package.document : package
  copy_package_parts_to_document(package, doc)
  doc  # Returns DocumentRoot, not DocxPackage!
```

**Fix**: Either:
1. Update test to expect `DocumentRoot` instead of `DocxPackage`
2. Or change `from_file` to return `DocxPackage`

Given "model-driven" approach, option 1 is preferred (tests should match actual API behavior).

### resource_roundtrip_spec.rb:172

**Styleset extraction issue**: Need to investigate why styleset extraction fails.

## Implementation

### Fix 1: format_converter_spec.rb

Update `spec/uniword/format_converter_spec.rb` line 345:
```ruby
subject(:failed_result) do
  Uniword::FormatConverter::ConversionResult.new(  # Explicit class reference
    source: 'input.docx',
    source_format: :docx,
    target: 'output.mhtml',
    target_format: :mhtml,
    success: false,
    error: 'File not found'
  )
end
```

### Fix 2: document_writer_spec.rb

Update test expectation at line 161:
```ruby
expect(loaded_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
```

## Files to Modify

- `spec/uniword/format_converter_spec.rb`
- `spec/uniword/document_writer_spec.rb`
- `spec/uniword/resource/resource_roundtrip_spec.rb` (needs investigation)

## Verification

```bash
bundle exec rspec spec/uniword/format_converter_spec.rb:355
bundle exec rspec spec/uniword/document_writer_spec.rb:152
```
