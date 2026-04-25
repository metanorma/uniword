# Bug 06: `standalone="yes"` missing from all XML declarations

## Severity: Low
Word accepts files without `standalone="yes"` but always adds it during save. Other XML validators may flag this as non-compliant OPC.

## Summary

All XML files serialized by uniword output:
```xml
<?xml version="1.0" encoding="UTF-8"?>
```

But Word expects:
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
```

## Root cause

All `to_xml` calls in `package_serialization.rb` pass `declaration: true` but NOT `standalone: true`:

```ruby
# Line 33
content["[Content_Types].xml"] = content_types.to_xml(encoding: "UTF-8", declaration: true)
# Line 34
content["_rels/.rels"] = package_rels.to_xml(encoding: "UTF-8", declaration: true)
# Line 37
content["docProps/core.xml"] = core_properties.to_xml(encoding: "UTF-8", prefix: true)
# ... etc
```

lutaml-model DOES support `standalone: true`:
```ruby
rels.to_xml(encoding: "UTF-8", declaration: true, standalone: true)
# => <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
```

## Fix

Add `standalone: true` to all `to_xml` calls in `package_serialization.rb`:

```ruby
content["[Content_Types].xml"] = content_types.to_xml(encoding: "UTF-8", declaration: true, standalone: true)
content["_rels/.rels"] = package_rels.to_xml(encoding: "UTF-8", declaration: true, standalone: true)
content["docProps/core.xml"] = core_properties.to_xml(encoding: "UTF-8", prefix: true, standalone: true)
# ... for all parts
```

Or create a constant for the common options:
```ruby
DOCX_XML_OPTS = { encoding: "UTF-8", declaration: true, standalone: true }.freeze
DOCX_XML_PREFIX_OPTS = { encoding: "UTF-8", prefix: true, standalone: true }.freeze
```
