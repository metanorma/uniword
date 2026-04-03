# Plan: Fix Enhanced Properties Round-Trip Specs

## Problem

Two tests fail in `enhanced_properties_roundtrip_spec.rb`:
- `preserves text effects through round-trip` (line 198)
- `preserves multiple run properties through round-trip` (line 240)

The issue is that `outline`, `shadow`, `emboss` text effects return `false` after round-trip.

## Root Cause Analysis

### 1. The `outline` Property Issue

In `RunProperties`:
```ruby
attribute :outline_level, Properties::OutlineLevel, default: nil
xml do
  map_element 'outline', to: :outline_level, render_nil: false
end
```

But `Properties::OutlineLevel` class defines:
```ruby
class OutlineLevel < Lutaml::Model::Serializable
  element 'outlineLvl'  # WRONG ELEMENT NAME for run's outline effect
  map_attribute 'val', to: :value
end
```

The problem: `RunProperties` maps XML element `w:outline` (boolean text effect) to `outline_level` attribute which uses `OutlineLevel` class that serializes as `w:outlineLvl` (integer for paragraph outline level).

### 2. The `shadow`/`emboss` Properties Issue

In `RunProperties`:
```ruby
attribute :_shadow_val, Properties::Shadow, default: nil
attribute :_emboss_val, Properties::Emboss, default: nil
xml do
  map_element 'shadow', to: :_shadow_val, render_nil: false
  map_element 'emboss', to: :_emboss_val, render_nil: false
end
```

These use custom getters/setters pattern which violates the "no custom getters/setters" rule.

## Fix Approach (Model-Driven, No Custom Getters/Setters)

### Fix 1: Create Proper `Outline` Property Class

Create `lib/uniword/properties/outline.rb`:
```ruby
class Outline < Lutaml::Model::Serializable
  include Uniword::Properties::BooleanElement
  attribute :val, :string, default: nil
  include Uniword::Properties::BooleanValSetter

  xml do
    element 'outline'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :val, render_nil: false, render_default: false
  end
end
```

Update `RunProperties`:
- Change `attribute :outline_level` to `attribute :outline` (type: `Properties::Outline`)
- Remove custom `outline` and `outline=` getter/setter methods
- Remove custom `outline?` method
- Change XML mapping to `map_element 'outline', to: :outline`

### Fix 2: Create Proper `Shadow`/`Emboss` Without Custom Getters

The current `Shadow` and `Emboss` classes use `BooleanValSetter` which is a custom module. We need to ensure they work with lutaml-model's default attribute mechanism.

Actually, `Shadow` and `Emboss` classes are already defined correctly. The issue is in how `RunProperties` uses them with custom getters/setters.

For `RunProperties`:
- Remove custom `shadow`, `shadow=`, `shadow?` methods
- Remove custom `emboss`, `emboss=`, `emboss?` methods
- Use direct attribute access via lutaml-model

But wait - the attributes are named `_shadow_val` and `_emboss_val` to avoid conflicting with element names. This is a workaround for the fact that we can't have an attribute named `shadow` that maps to XML element `shadow` without conflict.

Actually, we CAN have:
```ruby
attribute :shadow, Properties::Shadow
xml do
  map_element 'shadow', to: :shadow
end
```

This should work in lutaml-model - the attribute name and element name can be the same when using `map_element`.

## Implementation Steps

1. Create `lib/uniword/properties/outline.rb` with proper `Outline` class
2. Update `RunProperties` to use `outline` attribute of type `Properties::Outline`
3. Rename `_shadow_val` to `shadow` and `_emboss_val` to `emboss`
4. Remove all custom getter/setter methods from `RunProperties`
5. Update tests to use `.to be_truthy` instead of `.to be true` for wrapper checks

## Files to Modify

- `lib/uniword/properties/outline.rb` (NEW)
- `lib/uniword/wordprocessingml/run_properties.rb`
- `spec/uniword/enhanced_properties_roundtrip_spec.rb` (update assertions)

## Verification

```bash
bundle exec rspec spec/uniword/enhanced_properties_roundtrip_spec.rb
```
