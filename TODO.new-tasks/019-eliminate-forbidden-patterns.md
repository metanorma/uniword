# 019: Eliminate forbidden patterns (respond_to?, public_send, send)

## Status: DONE

## Problem

The user's global instructions strictly forbid `respond_to?`, `public_send`,
`instance_variable_set/get`, and `send` in all code. Several files on this
branch still use these patterns:

### `respond_to?` — forbidden (poor typing)

1. **`lib/uniword/builder/document_builder.rb:41`**
   ```ruby
   @model.allocator = allocator if allocator && @model.respond_to?(:allocator=)
   ```
   Fix: `DocumentRoot` is a known class — it has `attr_accessor :allocator`
   already. The check is unnecessary. Use:
   ```ruby
   @model.allocator = allocator if allocator
   ```

### `public_send` — forbidden (breaks encapsulation)

2. **`lib/uniword/builder/chart_builder.rb:270`**
   ```ruby
   xml["c"].public_send(tag) do
   ```
   Fix: Replace with explicit case dispatch:
   ```ruby
   case tag
   when :valAxis then xml["c"].valAxis { yield }
   when :catAxis then xml["c"].catAxis { yield }
   when :serAxis then xml["c"].serAxis { yield }
   end
   ```

3. **`lib/uniword/wordprocessingml/run.rb:187-201`**
   ```ruby
   override_val = override.public_send(attr_name)
   base_val = base.public_send(attr_name)
   merged.public_send(:"#{attr_name}=", value)
   ```
   Fix: Use lutaml-model's built-in attribute access:
   ```ruby
   override.attribute_value(attr_name)
   # or explicit dispatch based on attribute type
   ```

4. **`lib/uniword/diff/document_differ.rb:443,455,469`**
   ```ruby
   val = props.public_send(method)
   val = cp.public_send(field)
   ```
   Fix: Replace with explicit method calls or use lutaml-model's
   `attribute_value` API.

### `send` — forbidden (breaks encapsulation)

5. **`spec/uniword/builder/image_enhancements_spec.rb:189-226`**
   ```ruby
   pic = described_class.send(:build_picture, "rId1", 500_000, 300_000)
   ```
   Fix: Make `build_picture` a public class method (it's a factory method,
   not an implementation detail) or test through the public `create_drawing`
   API.

## Priority
All four categories must be fixed. `respond_to?` and `public_send` in library
code are highest priority. `send` in specs is lower priority but still required.

## Files
- `lib/uniword/builder/document_builder.rb` (line 41)
- `lib/uniword/builder/chart_builder.rb` (line 270)
- `lib/uniword/wordprocessingml/run.rb` (lines 187-201)
- `lib/uniword/diff/document_differ.rb` (lines 443, 455, 469)
- `spec/uniword/builder/image_enhancements_spec.rb` (lines 189-226)
