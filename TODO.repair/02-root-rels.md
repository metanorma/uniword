# 02. _rels/.rels: Fix rId assignment to match Word convention

## Problem

Our output assigns rIds in a different order than Word expects:

```xml
<!-- OUR OUTPUT -->
<Relationship Id="rId1" Type=".../officeDocument" Target="word/document.xml"/>
<Relationship Id="rId2" Type=".../extended-properties" Target="docProps/app.xml"/>
<Relationship Id="rId3" Type=".../metadata/core-properties" Target="docProps/core.xml"/>
```

```xml
<!-- WORD OUTPUT -->
<Relationship Id="rId3" Type=".../extended-properties" Target="docProps/app.xml"/>
<Relationship Id="rId2" Type=".../metadata/core-properties" Target="docProps/core.xml"/>
<Relationship Id="rId1" Type=".../officeDocument" Target="word/document.xml"/>
```

Note: Word uses rId3 for app.xml and rId2 for core.xml. The order and assignment differ.

## Rule

The rId values must be stable and consistent with what Word generates. The standard Word convention for `_rels/.rels` is:

| rId   | Type                          | Target              |
|-------|-------------------------------|---------------------|
| rId1  | officeDocument                | word/document.xml   |
| rId2  | metadata/core-properties      | docProps/core.xml   |
| rId3  | extended-properties           | docProps/app.xml    |

(Verify the exact mapping by testing with a fresh Word document.)

## Implementation

In `PackageSerialization`, when building `_rels/.rels`, ensure the rId assignment follows Word's convention, not arbitrary ordering. The Relationship elements should be written in a deterministic order.
