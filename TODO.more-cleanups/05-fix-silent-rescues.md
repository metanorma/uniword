# 05: Fix remaining bare rescue StandardError

**Priority:** P0 (data loss / silent bugs)
**Effort:** Small (~1 hour)
**Files:**
- `lib/uniword/mhtml/math_converter.rb:50,77`
- `lib/uniword/template/helpers/filter_helper.rb:73,86,99`

## Problem

Five instances of bare `rescue StandardError` without logging — the same silent
swallowing pattern fixed in TODO.improvements #05.

### math_converter.rb (2 instances)

```ruby
rescue StandardError
  # Silently skips math conversion failures
end
```

When Plurimath fails to parse an equation, the error is silently swallowed and
the math element is dropped from output. No way to know equations were lost.

### filter_helper.rb (3 instances)

```ruby
rescue StandardError
  # Silently skips filter application failures
end
```

Template filters that fail (typos, missing data, type errors) are silently
dropped. Template output silently omits content.

## Fix

Add logging to each:

```ruby
# math_converter.rb
rescue StandardError => e
  Uniword.logger&.debug { "Math conversion failed: #{e.message}" }
  fallback_output
end

# filter_helper.rb
rescue StandardError => e
  Uniword.logger&.debug { "Filter #{filter_name} failed: #{e.message}" }
  nil
end
```

For math_converter, also consider whether Plurimath errors should be caught
more narrowly (e.g., `rescue Plurimath::ParseError`).

## Verification

```bash
bundle exec rspec spec/uniword/math/ spec/uniword/template/
```
