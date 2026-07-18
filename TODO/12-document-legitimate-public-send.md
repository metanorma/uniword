# 20 — Eliminate remaining `public_send` sites

**Status: COMPLETED via TODO.validate/12** — the directive forbids all
dynamic dispatch, so no "legitimate" exceptions remain:
`element_serializer.rb:309,325` now reads through the schema-guarded
public method table (`element.method(name).call` behind the
`element.class.attributes.key?` allowlist), and
`variable_resolver.rb:116` uses case/on-class dispatch with a
declared-attribute allowlist for Lutaml models.
`grep -rn "public_send" lib/uniword/` returns 0 hits.

**Priority:** Low (most are legitimate dynamic dispatch)
**Files:**
- `lib/uniword/ooxml/schema/element_serializer.rb` (2 sites)
- `lib/uniword/template/variable_resolver.rb` (1 site)

## Problem

These three sites use `public_send` for legitimate dynamic dispatch
over user-provided objects. They are not the same pattern as the
already-fixed violations (style_definition, color_scheme, cli/main,
theme_xml_parser).

## Site analysis

### `element_serializer.rb:306, 322`
```ruby
element.public_send(property_name)
```
Schema-driven serializer reading attribute values from any
`Lutaml::Model::Serializable` subclass. The `property_name` comes from
the schema definition (not user input). This is the canonical Ruby
idiom for serializing arbitrary models — there's no clean alternative
without rewriting `lutaml-model` itself.

### `variable_resolver.rb:112`
```ruby
object.public_send(property.to_sym)
```
Template-driven property access on arbitrary user objects. The
`property` comes from template syntax. Risk: this allows templates
to call ANY public method on the model, including potentially
dangerous ones.

## Fix considerations

### For element_serializer
Could be replaced with `Lutaml::Model`'s typed attribute access if
such an API exists in a future version. Track upstream.

### For variable_resolver
Add an allowlist of property names per object class:
```ruby
ALLOWED_PROPERTIES = {
  DocumentRoot => %i[title creator subject keywords],
  Body => %i[paragraphs tables],
  # ...
}.freeze

def navigate_property(object, property)
  if object.is_a?(Hash)
    object[property.to_sym] || object[property]
  else
    return unless property_allowed?(object, property)
    object.public_send(property.to_sym)
  end
end
```

## Verification

After fix: `grep -rn "public_send" lib/uniword/` returns 0 (or only
documented exceptions).
