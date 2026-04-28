# 03. word/_rels/document.xml.rels: Add theme relationship, fix rId order

## Problem

Our output is missing the theme relationship and has different rId assignments:

```xml
<!-- OUR OUTPUT (missing theme) -->
<Relationship Id="rId1" Type=".../styles" Target="styles.xml"/>
<Relationship Id="rId2" Type=".../fontTable" Target="fontTable.xml"/>
<Relationship Id="rId3" Type=".../settings" Target="settings.xml"/>
<Relationship Id="rId4" Type=".../webSettings" Target="webSettings.xml"/>
```

```xml
<!-- WORD OUTPUT -->
<Relationship Id="rId3" Type=".../webSettings" Target="webSettings.xml"/>
<Relationship Id="rId2" Type=".../settings" Target="settings.xml"/>
<Relationship Id="rId1" Type=".../styles" Target="styles.xml"/>
<Relationship Id="rId5" Type=".../theme" Target="theme/theme1.xml"/>
<Relationship Id="rId4" Type=".../fontTable" Target="fontTable.xml"/>
```

Word adds `rId5` for `theme/theme1.xml`. The absence of a theme relationship causes Word to add one during repair.

## Rule

When a theme file (`word/theme/theme1.xml`) is present in the package, there MUST be a corresponding relationship:

```xml
<Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme"
              Target="theme/theme1.xml"/>
```

The standard rId mapping for `word/_rels/document.xml.rels`:

| rId   | Type       | Target                |
|-------|------------|-----------------------|
| rId1  | styles     | styles.xml            |
| rId2  | settings   | settings.xml          |
| rId3  | webSettings| webSettings.xml        |
| rId4  | fontTable  | fontTable.xml          |
| rId5  | theme      | theme/theme1.xml       |

## Implementation

In `PackageSerialization`, when building `word/_rels/document.xml.rels`:
1. Include the theme relationship when `word/theme/theme1.xml` is present.
2. Ensure rId numbering follows Word convention.
