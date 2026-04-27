# 03: Make DocumentRoot.valid? meaningful

**Priority:** P0 (bug — false validation confidence)
**Effort:** Small (~1 hour)
**File:** `lib/uniword/wordprocessingml/document_root.rb:161-165`

## Problem

`DocumentRoot#valid?` is trivially true — it only checks that `body` exists,
and `body` has a default value so it's always present. The CLI `validate`
command (`cli.rb:703`) reports success based on this, giving users false
confidence their documents are correct.

```ruby
# Current implementation (lines 161-165):
def valid?
  return false unless body
  true
end
```

The `verify` command uses the separate 3-layer validation pipeline (OPC + XSD +
semantic rules), but `validate` only calls `valid?`.

## Fix

Two options:

**Option A: Make valid? run the validation pipeline**

```ruby
def valid?
  return false unless body

  # Check body has content
  return false if body.paragraphs.empty?

  # Run semantic validation rules
  errors = Uniword::Validation.validate(self)
  errors.empty?
end
```

**Option B: Make validate CLI use the verify pipeline**

In `cli.rb`, change the `validate` command to delegate to the 3-layer
verification pipeline (already implemented for the `verify` command), possibly
with a lighter ruleset for quick checks.

## Verification

```bash
bundle exec rspec spec/uniword/wordprocessingml/document_root_spec.rb
bundle exec rspec spec/uniword/validation/
```
