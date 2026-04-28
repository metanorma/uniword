# 05: Replace silent exception swallowing with logging

**Priority:** P0 (data corruption / bugs pass silently)
**Effort:** Small (~1 hour)
**Files:**
- `lib/uniword/wordprocessingml/run.rb:200`
- `lib/uniword/transformation/ooxml_to_mhtml_converter.rb:438`
- `lib/uniword/streaming_parser.rb:42`

## Problem

Three locations catch `StandardError` and silently discard the error, hiding
real bugs and data corruption from users and developers.

### 1. run.rb:200 — attribute merging

```ruby
rescue StandardError
  # Skip attributes that can't be set
end
```

This hides typos in attribute names, type mismatches, and data corruption.
Any attribute that fails to merge is silently dropped. There is no way to
know that data was lost.

### 2. ooxml_to_mhtml_converter.rb:438 — document name extraction

```ruby
rescue StandardError
  "document"
end
```

Falls back to `"document"` on any error. Encoding issues, nil references,
and logic errors are silently hidden.

### 3. streaming_parser.rb:42 — streaming decision

```ruby
rescue StandardError
  false
end
```

The `should_stream?` method returns `false` on any error, including file
permission errors, encoding errors, and actual bugs. The parser silently
falls back to non-streaming mode.

## Fix

Replace each with targeted error handling + logging:

```ruby
# run.rb — log the attribute that failed
rescue StandardError => e
  Uniword.logger.debug { "Skipping attribute #{attr_name}: #{e.message}" }
end

# ooxml_to_mhtml_converter.rb — log the fallback
rescue StandardError => e
  Uniword.logger.debug { "Falling back to 'document' name: #{e.message}" }
  "document"
end

# streaming_parser.rb — only catch expected errors
rescue Errno::ENOENT, Errno::EACCES
  false
```

For run.rb, also consider: should we re-raise for unexpected errors? The
attribute merge is best-effort, but `NoMethodError` or `TypeError` indicate
a real bug, not bad data.

## Verification

```bash
bundle exec rspec
# Ensure no tests depend on the silent swallowing behavior
```
