# Dual-Namespace Same-Named Element Deserialization — RESOLVED

## Status: FIXED

The lutaml-model team at `lutaml-model-new` has implemented a fix using the
decision engine approach.

**Fix Summary**

Problem: When deserializing XML with dual-namespace same-named elements (m:rPr and
w:rPr), the round-trip serialization was not preserving the correct namespace
prefixes.

Solution: Created a new `UsedPrefixRule` (priority 0.15) that preserves the used
prefix from deserialization for round-trip fidelity.

Key Insight: The distinction between dual-namespace and dcterms cases is the
`element_form_default` setting:
- Dual-namespace (Word/Math) namespaces have `element_form_default :qualified` set
- dcterms namespace does NOT have `element_form_default` set

By checking `element_form_default == :qualified` in `UsedPrefixRule`:
- Dual-namespace elements → Rule applies, preserving prefix format (e.g., w:rPr)
- dcterms elements → Rule doesn't apply, falls through to DefaultPreferenceRule
  which outputs default format (e.g., `<created xmlns="...">`)

## Files Created/Modified

| File | Change |
|------|--------|
| `lib/lutaml/xml/decisions/rules/used_prefix_rule.rb` | NEW — UsedPrefixRule |
| `lib/lutaml/xml/decisions/rules.rb` | Added `used_prefix_rule.rb` |
| `lib/lutaml/xml/decisions/decision_engine.rb` | Updated decision engine |
| `lib/lutaml/xml/decisions/decision_context.rb` | Added `element_used_prefix` |
| `lib/lutaml/xml/decisions/element_prefix_resolver.rb` | Added `element_used_prefix` |
| `lib/lutaml/xml/declaration_planner.rb` | Updated to support used prefix |
| `spec/lutaml/xml/dual_namespace_element_spec.rb` | New test |

## Verification

```bash
# In lutaml-model-new
bundle exec rspec spec/lutaml/xml/dual_namespace_element_spec.rb
# 5 examples, 0 failures

bundle exec rspec spec/lutaml/xml/
# 1366 examples, 0 failures

# In uniword (with Gemfile pointing to lutaml-model-new)
bundle exec ruby -e '
require "uniword"
math_ns = "http://schemas.openxmlformats.org/officeDocument/2006/math"
wml_ns = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
xml = <<~XML
<m:r xmlns:m="#{math_ns}" xmlns:w="#{wml_ns}">
  <m:rPr><m:scr w:val="roman"/></m:rPr>
  <w:rPr><w:rFonts w:ascii="Times New Roman"/></w:rPr>
  <m:t>hello</m:t>
</m:r>
XML
run = Uniword::Math::MathRun.from_xml(xml)
puts "word_properties.__xml_namespace_prefix: #{run.word_properties.instance_variable_get(:@__xml_namespace_prefix).inspect}"
puts "word_properties.fonts: #{run.word_properties&.fonts&.ascii.inspect}"
output = run.to_xml
puts "to_xml includes w:rPr: #{output.include?("<w:rPr")}"
puts "to_xml includes m:rPr: #{output.include?("<m:rPr")}"
'
# word_properties.__xml_namespace_prefix: "w"  ✓
# word_properties.fonts: "Times New Roman"    ✓
# to_xml includes w:rPr: true                 ✓
# to_xml includes m:rPr: true                 ✓
```

## Root Cause (for reference)

The original code in `model_transform.rb` lines 566-583 had a condition:

```ruby
parent_has_explicit_prefix = instance.instance_variable_get(:@__xml_namespace_prefix)
if parent_has_explicit_prefix.to_s.empty?
  cast_result.instance_variable_set(:@__xml_namespace_prefix, ns_prefix)
end
```

This only set `@__xml_namespace_prefix` on a child when the parent's prefix was
empty. In the dual-namespace case, the parent (MathRun) had prefix `"m"` from its
root element, so the condition failed and `word_properties` never got its prefix
set, causing the wrong namespace to be used during serialization.

The fix uses the decision engine's `UsedPrefixRule` (priority 0.15) to handle
round-trip preservation of used prefixes, checking `element_form_default == :qualified`
to distinguish dual-namespace elements from dcterms-style elements.

## Uniword Gemfile

Uniword's `Gemfile` currently points to `lutaml-model-new` for testing:

```ruby
gem 'lutaml-model', path: '/Users/mulgogi/src/lutaml/lutaml-model-new'
```

When the fix is merged into the main `lutaml-model` repo, update to:

```ruby
gem 'lutaml-model', path: '/Users/mulgogi/src/lutaml/lutaml-model'
```
