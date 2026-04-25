# 08. word/settings.xml: Populate with Word-required defaults

## Problem

Our output is empty:

```xml
<!-- OUR OUTPUT -->
<w:settings xmlns:m="..." xmlns:mc="..." xmlns:o="..." xmlns:sl="..." xmlns:w="..." xmlns:w14="..." xmlns:w15="..."/>
```

Word requires extensive content:

```xml
<!-- WORD OUTPUT -->
<w:settings xmlns:mc="..." xmlns:o="..." xmlns:r="..." xmlns:m="..." xmlns:v="..."
  xmlns:w10="..." xmlns:w="..." xmlns:w14="..." xmlns:w15="..."
  xmlns:w16cex="..." xmlns:w16cid="..." xmlns:w16="..." xmlns:w16du="..."
  xmlns:w16sdtdh="..." xmlns:w16sdtfl="..." xmlns:w16se="..." xmlns:sl="..."
  mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du">

  <w:zoom w:percent="100"/>
  <w:doNotDisplayPageBoundaries/>
  <w:proofState w:spelling="clean" w:grammar="clean"/>
  <w:defaultTabStop w:val="720"/>
  <w:characterSpacingControl w:val="doNotCompress"/>

  <w:compat>
    <w:useFELayout/>
    <w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="15"/>
    <w:compatSetting w:name="overrideTableStyleFontSizeAndJustification" w:uri="http://schemas.microsoft.com/office/word" w:val="1"/>
    <w:compatSetting w:name="enableOpenTypeFeatures" w:uri="http://schemas.microsoft.com/office/word" w:val="1"/>
    <w:compatSetting w:name="doNotFlipMirrorIndents" w:uri="http://schemas.microsoft.com/office/word" w:val="1"/>
    <w:compatSetting w:name="differentiateMultirowTableHeaders" w:uri="http://schemas.microsoft.com/office/word" w:val="1"/>
    <w:compatSetting w:name="useWord2013TrackBottomHyphenation" w:uri="http://schemas.microsoft.com/office/word" w:val="0"/>
  </w:compat>

  <w:rsids>
    <w:rsidRoot w:val="00AA6FE3"/>
    <w:rsid w:val="00AA6FE3"/>
    <w:rsid w:val="00B3444E"/>
    <w:rsid w:val="00CC36F9"/>
  </w:rsids>

  <m:mathPr>
    <m:mathFont m:val="Cambria Math"/>
    <m:brkBin m:val="before"/>
    <m:brkBinSub m:val="--"/>
    <m:smallFrac m:val="0"/>
    <m:dispDef/>
    <m:lMargin m:val="0"/>
    <m:rMargin m:val="0"/>
    <m:defJc m:val="centerGroup"/>
    <m:wrapIndent m:val="1440"/>
    <m:intLim m:val="subSup"/>
    <m:naryLim m:val="undOvr"/>
  </m:mathPr>

  <w:themeFontLang w:val="en-US" w:eastAsia="zh-CN"/>
  <w:clrSchemeMapping
    w:bg1="light1" w:t1="dark1" w:bg2="light2" w:t2="dark2"
    w:accent1="accent1" w:accent2="accent2" w:accent3="accent3"
    w:accent4="accent4" w:accent5="accent5" w:accent6="accent6"
    w:hyperlink="hyperlink" w:followedHyperlink="followedHyperlink"/>
  <w:decimalSymbol w:val="."/>
  <w:listSeparator w:val=","/>

  <w14:docId w14:val="0DFBF0C3"/>
  <w15:docId w15:val="{388A1DFF-9989-B145-B0A6-99AA77B8E333}"/>
</w:settings>
```

## Required elements

### 1. Zoom
```xml
<w:zoom w:percent="100"/>
```

### 2. Display settings
```xml
<w:doNotDisplayPageBoundaries/>
```

### 3. Proof state
```xml
<w:proofState w:spelling="clean" w:grammar="clean"/>
```

### 4. Default tab stop
```xml
<w:defaultTabStop w:val="720"/>
```

### 5. Character spacing
```xml
<w:characterSpacingControl w:val="doNotCompress"/>
```

### 6. Compatibility settings
All six `compatSetting` entries are required. The `compatibilityMode` value of `15` means Word 2013+ mode.

### 7. rsids (revision save IDs)
Generate at least one rsid per save operation. Format: 8-hex-char uppercase string.
- `rsidRoot` = the first rsid used
- Additional `rsid` entries for each editing session

### 8. Math properties
The full `m:mathPr` block is required. Values shown above are Word defaults.

### 9. Theme font language
```xml
<w:themeFontLang w:val="en-US" w:eastAsia="zh-CN"/>
```
Language values should be configurable via user profile.

### 10. Color scheme mapping
The full `clrSchemeMapping` with all 10 attributes is required.

### 11. Locale settings
```xml
<w:decimalSymbol w:val="."/>
<w:listSeparator w:val=","/>
```
Values depend on user locale.

### 12. Document IDs (w14/w15)
```xml
<w14:docId w14:val="0DFBF0C3"/>
<w15:docId w15:val="{388A1DFF-9989-B145-B0A6-99AA77B8E333}"/>
```
Auto-generated unique IDs. `w14:docId` is 8 hex chars. `w15:docId` is a GUID.

### Missing namespaces
The `settings.xml` also needs additional namespace declarations: `r`, `v`, `w10`, and the w16* namespaces, plus `mc:Ignorable`.

## Implementation

1. Define a "default settings" repair rule that populates all these elements.
2. Some values are user-profile-configurable: `themeFontLang`, `decimalSymbol`, `listSeparator`.
3. Some are auto-generated: `rsids`, `docId`.
4. Math properties have fixed defaults.
5. Color scheme mapping maps theme color names to themselves by default.
