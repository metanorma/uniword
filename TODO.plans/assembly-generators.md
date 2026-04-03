# Plan: Fix Assembly and Generator Specs

## Problem

Tests in assembly/generator specs fail related to text extraction and variable substitution.

## Failing Tests

### toc_generator_spec.rb
- `includes title paragraph` - **FIXED** (be_truthy)

### document_assembler_spec.rb (2 failures)
- `applies variable substitution` - line 101
- `accepts variable overrides` - line 110

### variable_substitutor_spec.rb (1 failure)
- `substitutes variables in document paragraphs` - line 112

### text_extractor_spec.rb (1 failure)
- `extracts text from mixed content document` - line 196

## Root Cause Analysis

### variable_substitutor_spec.rb:112

```ruby
def substitute_run(run)
  return unless run.text
  run.text = substitute(run.text)  # BUG: run.text is a Text object, not String
end
```

The `substitute` method expects a String:
```ruby
def substitute(text)
  return text unless text.is_a?(String)  # Returns early for Text object!
  # ...
end
```

But `run.text` returns the `Text` object (lutaml-model attribute), not a String.

**Fix**: Extract string content before substitution:
```ruby
def substitute_run(run)
  return unless run.text
  content = run.text.to_s
  run.text = substitute(content)
end
```

### text_extractor_spec.rb:196

```
expected: "This is a paragraph.\nHeader 1 | Header 2\nData 1 | Data 2\nFinal paragraph"
got: "This is a paragraph.\nFinal paragraph"
```

The table content is not being extracted. The `TextExtractor` visitor likely doesn't visit Table elements.

### document_assembler_spec.rb:101

The test creates a document with variables and expects substitution. Similar issue to variable_substitutor.

## Fix Approach (Model-Driven)

### 1. Fix VariableSubstitutor

File: `lib/uniword/assembly/variable_substitutor.rb`

Change `substitute_run` to use string content:
```ruby
def substitute_run(run)
  return unless run.text
  content = run.text.to_s
  run.text = substitute(content)
end
```

### 2. Fix TextExtractor

Check if TextExtractor has visit methods for Table, TableRow, TableCell. If not, add them.

### 3. Update document_assembler_spec.rb

Check if similar Text object issue exists.

## Files to Modify

- `lib/uniword/assembly/variable_substitutor.rb`
- `lib/uniword/visitor/text_extractor.rb` (if visit methods missing)
- `spec/uniword/assembly/variable_substitutor_spec.rb` (if test assertions need updating)

## Verification

```bash
bundle exec rspec spec/uniword/assembly/variable_substitutor_spec.rb:112
bundle exec rspec spec/uniword/visitor/text_extractor_spec.rb:196
```
