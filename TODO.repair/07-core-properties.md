# 07. docProps/core.xml: Add revision and lastModifiedBy

## Problem

Our output is missing `cp:lastModifiedBy` and `cp:revision`. Also, the `xmlns:dcmitype` namespace is already fixed in the model but needs to always be present.

```xml
<!-- OUR OUTPUT (missing fields) -->
<cp:coreProperties xmlns:cp="..." xmlns:dc="..." xmlns:dcterms="..." xmlns:xsi="...">
  <dc:title/>
  <dc:subject/>
  <dc:creator/>
  <cp:keywords/>
  <dc:description/>
  <dcterms:created xsi:type="dcterms:W3CDTF">2026-04-21T05:26:29+08:00</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">2026-04-21T05:26:29+08:00</dcterms:modified>
</cp:coreProperties>
```

```xml
<!-- WORD OUTPUT -->
<cp:coreProperties xmlns:cp="..." xmlns:dc="..." xmlns:dcmitype="..." xmlns:dcterms="..." xmlns:xsi="...">
  <dc:title></dc:title>
  <dc:subject></dc:subject>
  <dc:creator></dc:creator>
  <cp:keywords></cp:keywords>
  <dc:description></dc:description>
  <cp:lastModifiedBy>Ronald Tse</cp:lastModifiedBy>
  <cp:revision>1</cp:revision>
  <dcterms:created xsi:type="dcterms:W3CDTF">2026-04-20T21:26:00Z</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">2026-04-20T21:27:00Z</dcterms:modified>
</cp:coreProperties>
```

## Rule

### Fields to add:

| Field               | Value                                | Notes                                    |
|---------------------|--------------------------------------|------------------------------------------|
| `cp:lastModifiedBy` | From user profile                    | The name of the last person who modified  |
| `cp:revision`       | Auto-incremented integer, e.g. `"1"` | Incremented on each save                 |

### Notes:

- `lastModifiedBy` is **user-provided**, NOT auto-generated. It should come from the user profile or application configuration. This is the user's name/identity.
- `revision` starts at `"1"` and should increment on each save. This tracks document revision count.
- `xmlns:dcmitype` namespace must always be declared (already fixed in model).
- `xsi:type="dcterms:W3CDTF"` must be present on created/modified (already fixed).
- Timestamps: `created` should be preserved from first creation, `modified` should be updated on each save. Format should use UTC (`Z` suffix), not local timezone offset.

## Implementation

1. Add `last_modified_by` and `revision` attributes to `CoreProperties` model (already has `CpLastModifiedByType` and `CpRevisionType` in types).
2. In `initialize`, default `revision` to `"1"`.
3. Accept `lastModifiedBy` from user profile configuration.
4. On save, increment revision and update `modified` timestamp.
