# lutaml-model Issue: Same-Named Elements with Different Namespaces

## Status: FIXED (local), NEEDS PUSH to branch

**Fix Location**: `/Users/mulgogi/src/lutaml/lutaml-model/lib/lutaml/xml/transformation/rule_compiler.rb`

## Problem

When using `map_element` with attributes that have `Serializable` model types, the compiled rule's `namespace_class` was `nil`. This broke namespace-aware element matching during round-trip serialization for same-named elements from different namespaces (e.g., `w14:docId` vs `w15:docId`).

## Fix Applied (Local)

Changed 4 methods in `rule_compiler.rb` to use dual-path namespace lookup:

1. `compile_standard_element_rule` (line ~372)
2. `compile_standard_attribute_rule`
3. `compile_delegated_element_rule`
4. `compile_delegated_attribute_rule`

Pattern:
```ruby
namespace_class = mapping_rule.namespace_class
if !namespace_class && attr_type.is_a?(Class)
  if attr_type <= Lutaml::Model::Type::Value
    # Type::Value classes have namespace_class directly on the type
    namespace_class = attr_type.namespace_class
  elsif attr_type.include?(Lutaml::Model::Serialize) && attr_type.respond_to?(:mappings_for)
    # Serializable models have namespace on their mapping
    type_mapping = attr_type.mappings_for(:xml, register_id)
    namespace_class = type_mapping.namespace_class if type_mapping
  end
end
```

## Current Gemfile Config

```ruby
gem 'lutaml-model', path: '/Users/mulgogi/src/lutaml/lutaml-model'
```

## Verification

```bash
bundle exec ruby -e "
require 'lutaml/model'
require_relative 'lib/uniword'
original_xml = File.read('examples/roundtrip_spec_original/word/settings.xml')
settings = Uniword::Wordprocessingml::Settings.from_xml(original_xml)
serialized = settings.to_xml
puts serialized.scan(/<w14:docId[^>]*>|<w15:docId[^>]*>/)
"
# Output:
# <w14:docId w14:val="4C6D0839"/>
# <w15:docId w15:val="{E36117BD-AEC7-3F4D-8270-E4063205A9DE}"/>
```

## Next Steps

1. Push the fix from local to the `feat/namespace-aware-roundtrip-serialization` branch
2. Update Gemfile to use the branch once fix is merged:
   ```ruby
   gem 'lutaml-model', github: "lutaml/lutaml-model", branch: "feat/namespace-aware-roundtrip-serialization"
   ```
3. Run tests to verify

## Related Files

- `lib/lutaml/xml/transformation/ordered_applier.rb` - uses `namespace_class` for namespace-aware matching
- `lib/lutaml/model/compiled_rule.rb` - stores `namespace_class` for use during serialization
- `lib/lutaml/xml/mapping_rule.rb` - handles namespace normalization
