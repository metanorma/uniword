# Lutaml-Model Bug Report: prefix: true Breaks Element Ordering

## Summary

When using `to_xml(prefix: true)` on models with `ordered` directive, child elements serialize in incorrect order, appearing to be "deleted" from their correct location and "inserted" at wrong locations.

## Environment

- **lutaml-model version**: 0.8.0+ (local development path: `/Users/mulgogi/src/lutaml/lutaml-model`)
- **Ruby version**: 3.3.2
- **Project**: Uniword (Word document library)

## Expected Behavior

When serializing a model hierarchy with `ordered` directive:
- Elements should serialize in the exact order they appear in the source XML
- `prefix: true` should ONLY affect namespace prefixes, not element ordering
- All child elements should remain in their declared positions

## Actual Behavior

When using `prefix: true`:
- Child elements serialize in WRONG order
- Canon XML comparison shows elements "deleted" from correct location
- Same elements appear "inserted" at different locations
- Functional data is preserved but structural order is corrupted

## Reproduction Case

### Simple Test (Works Correctly)

```ruby
class TestTheme < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :scheme_color, TestSchemeColor

  xml do
    root 'theme'
    namespace DrawingMLNamespace
    map_attribute 'name', to: :name
    map_element 'schemeClr', to: :scheme_color
  end
end

theme.to_xml(prefix: true)
# => Works correctly: <a:theme><a:schemeClr><a:tint/></a:schemeClr></a:theme>
```

### Complex Test (FAILS - Element Ordering Bug)

```ruby
# Real Uniword Theme class with deep hierarchy
theme = Uniword::Ooxml::ThmxPackage.from_file('Atlas.thmx')

# Without prefix: 1 difference (namespace declaration only)
xml1 = theme.to_xml
# => <theme xmlns="..."><themeElements><fmtScheme>...
#      <schemeClr val="phClr"><tint val="62000"/><alpha val="60000"/>...

# With prefix: 45 differences (element ordering corrupted!)
xml2 = theme.to_xml(prefix: true)
# => <a:theme xmlns:a="..."><a:themeElements><a:fmtScheme>...
#      <a:schemeClr val="phClr"><!-- tint MISSING from here -->...
#      <!-- tint appears at WRONG location later -->
```

### Canon XML Comparison Output

```
DIFFERENCE #1: Element deleted from /theme/.../schemeClr/tint
DIFFERENCE #5: Element inserted at /theme/.../schemeClr/tint (wrong location)

DIFFERENCE #2: Element deleted from /theme/.../schemeClr/alpha
DIFFERENCE #6: Element inserted at /theme/.../schemeClr/alpha (wrong location)

DIFFERENCE #3: Element deleted from /theme/.../schemeClr/satMod
DIFFERENCE #7: Element inserted at /theme/.../schemeClr/satMod (wrong location)
```

## Impact

### Critical Issues

1. **Round-trip fidelity broken**: Documents can't be loaded, modified, and saved while preserving structure
2. **Office compatibility risk**: Microsoft Office may reject documents with incorrect element ordering
3. **Semantic corruption**: While data is preserved, structure is wrong
4. **No workaround**: Cannot use namespace prefixes (required for many Office formats) without breaking ordering

### Current Workaround

**Accept namespace declaration difference instead of element ordering corruption:**

```ruby
# Use default namespace (xmlns=) instead of prefixed (xmlns:a=)
theme.to_xml  # 1 namespace difference (acceptable)

# DO NOT use prefix: true
theme.to_xml(prefix: true)  # 45 element ordering differences (unacceptable)
```

The 1 namespace declaration difference is **cosmetic and functionally equivalent**, while 45 element ordering differences represent **structural corruption**.

## Affected Code Patterns

### Pattern 1: Ordered Child Elements

```ruby
class SchemeColor < Lutaml::Model::Serializable
  attribute :val, :string
  attribute :tint, Tint
  attribute :alpha, Alpha
  attribute :sat_mod, SaturationModulation
  attribute :lum_mod, LuminanceModulation

  xml do
    element 'schemeClr'
    namespace DrawingMLNamespace
    ordered  # <-- This combined with prefix: true causes bug

    map_attribute 'val', to: :val
    map_element 'tint', to: :tint, render_nil: false
    map_element 'alpha', to: :alpha, render_nil: false
    map_element 'satMod', to: :sat_mod, render_nil: false
    map_element 'lumMod', to: :lum_mod, render_nil: false
  end
end
```

### Pattern 2: Parent with namespace_scope

```ruby
class Theme < Lutaml::Model::Serializable
  xml do
    root 'theme'
    namespace DrawingMLNamespace
    namespace_scope [DrawingMLNamespace]  # May interact with prefix: true
  end
end
```

## Test Results

| Configuration | Differences | Type | Acceptable? |
|---------------|-------------|------|-------------|
| No prefix, no namespace_scope | 1 | Namespace declaration | ✅ Yes (cosmetic) |
| No prefix, with namespace_scope | 1 | Namespace declaration | ✅ Yes (cosmetic) |
| With prefix: true | 45 | Element ordering | ❌ NO (structural) |

## Proposed Fix

### Option 1: Fix prefix: true Ordering (Ideal)

Ensure `prefix: true` respects `ordered` directive and maintains element sequence from `@element_order`.

### Option 2: Add ordered: true Parameter

```ruby
theme.to_xml(prefix: true, preserve_order: true)
```

### Option 3: Document Limitation

Add to documentation:

> **Known Limitation**: Using `prefix: true` with `ordered` directive may cause element ordering issues in complex hierarchies. For documents requiring both prefixed namespaces and strict element ordering, consider alternative serialization approaches or accept default namespace format.

## Severity

**HIGH** - Affects critical Office Open XML functionality where both namespace prefixes AND element ordering are required by spec

## Related Issues

- Affects Office Open XML theme files (.thmx)
- Affects any OOXML format requiring prefixed namespaces (WordprocessingML, SpreadsheetML, PresentationML)
- Impacts round-trip fidelity for complex documents

## Files for Investigation

- `lib/lutaml/model/xml/builder.rb` - XML serialization logic
- `lib/lutaml/model/serialize.rb` - to_xml implementation
- Element ordering handling when prefix mode is active

## Contact

- **Reporter**: Uniword project team
- **Project**: https://github.com/metanorma/uniword
- **Lutaml-model**: https://github.com/lutaml/lutaml-model