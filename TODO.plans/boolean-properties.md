# Plan: Fix Boolean Property Test Issues

## Problem

Tests in `run_properties_spec.rb` fail when creating boolean properties.

### Example Error
```ruby
props.bold = Uniword::Properties::Bold.new(value: false)
expect(props.bold?).to be false
# Expected: false, Got: true
```

## Root Cause

1. `Bold.new(value: false)` passes `:value` key
2. `Bold` class has `attribute :val, :string` (NOT `:value`)
3. The `:value` key is ignored, `@val` remains `nil`
4. `BooleanElement.value` returns `nil != 'false'` = `true`

### Correct Usage
```ruby
Bold.new(val: 'false')  # Sets @val to "false"
Bold.new(val: nil)      # Bold=true (absence means true)
```

## BooleanElement Module

The `BooleanElement` mixin provides:
- `value` - returns `@val != 'false'` (nil means true)
- `value=` - sets `@val` to nil (true) or 'false' (false)

But it works with `:val` attribute, not `:value`.

## Solution Options

### Option A: Fix Tests to Use Correct Parameter

Update tests to use `val:` instead of `value:`:

```ruby
Bold.new(val: 'false')  # Instead of Bold.new(value: false)
```

### Option B: Accept `:value` as Alias

Add handling in Bold to accept both `:val` and `:value`:

```ruby
def initialize(attributes = {})
  if attributes.key?(:value) && !attributes.key?(:val)
    attributes[:val] = attributes.delete(:value)
  end
  super
end
```

**Issue**: Custom setter in initialize (but not a getter/setter on attribute)

### Option C: Create Type That Accepts :value

Create custom type that maps `:value` to internal `:val`.

## Affected Specs

- `spec/uniword/properties/run_properties_spec.rb` - lines 49, 75, 128, 170
- `spec/uniword/properties/paragraph_properties_spec.rb` - line 35
- `spec/uniword/properties/table_properties_spec.rb` - line 14

## Note

This is likely a pre-existing test issue - tests use wrong parameter name.
