# Bug 02: Reconciler sets cp.modified/cp.created as plain String, crashes serialization

## Severity: FIXED

## Summary

~~In `Reconciler#reconcile_core_properties`, the `modified` and `created` attributes were set to plain Ruby `String` values. However, their declared types are `DctermsModifiedType` and `DctermsCreatedType` — both `Lutaml::Model::Serializable` subclasses that do NOT auto-coerce from `String`.~~

**Status: Fixed in commit `e48c309`.** The reconciler now creates proper model objects:

```ruby
cp.modified = Ooxml::Types::DctermsModifiedType.new(
  value: now, type: "dcterms:W3CDTF"
)
cp.created ||= Ooxml::Types::DctermsCreatedType.new(
  value: now, type: "dcterms:W3CDTF"
)
```

The core.xml also correctly declares all namespaces (xmlns:dcmitype included) because the reconciler rebuilds CoreProperties from scratch (`CoreProperties.new(...)`) rather than modifying the parsed object. This bypasses the lutaml-model "parsed namespace preservation" issue.
