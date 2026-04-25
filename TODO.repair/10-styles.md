# 10. word/styles.xml: Use Word's complete default style set

## Problem

Our output has a minimal set of programmatic styles. Word requires a much more complete set including `docDefaults`, `latentStyles`, and default style definitions.

### Our output (incomplete):
- Normal, DefaultParagraphFont, Heading1-6, Title, Heading11, TOC Heading
- No `docDefaults`
- No `latentStyles`
- Missing default table/numbering styles

### Word output requires:
1. `docDefaults` (run and paragraph property defaults)
2. `latentStyles` (376 latent style exceptions)
3. Default styles: Normal, DefaultParagraphFont, TableNormal, NoList
4. Custom styles (user-defined)

## Required: docDefaults

```xml
<w:docDefaults>
  <w:rPrDefault>
    <w:rPr>
      <w:rFonts w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorEastAsia"
                w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi"/>
      <w:kern w:val="2"/>
      <w:sz w:val="24"/>
      <w:szCs w:val="24"/>
      <w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/>
      <w14:ligatures w14:val="standardContextual"/>
    </w:rPr>
  </w:rPrDefault>
  <w:pPrDefault>
    <w:pPr>
      <w:spacing w:after="160" w:line="278" w:lineRule="auto"/>
    </w:pPr>
  </w:pPrDefault>
</w:docDefaults>
```

### Configurable values in docDefaults:
- `rFonts` themes: `minorHAnsi`, `minorEastAsia`, `minorBidi` -- depend on theme
- `lang` values: `en-US`, `zh-CN`, `ar-SA` -- depend on user locale
- `spacing` defaults: `after=160`, `line=278` (`lineRule=auto`) -- Word defaults

## Required: latentStyles

```xml
<w:latentStyles w:defLockedState="0" w:defUIPriority="99" w:defSemiHidden="0"
                w:defUnhideWhenUsed="0" w:defQFormat="0" w:count="376">
  <!-- ~200 lsdException entries -->
</w:latentStyles>
```

The full list of ~200 `lsdException` entries includes:
- Standard styles: Normal, heading 1-9, Title, Subtitle, Quote, etc.
- TOC styles: toc 1-9, toc heading
- List styles: List, List Bullet, List Number (+ variants)
- Table styles: Table Simple/Classic/Colorful/Grid/List variants + accent variants
- Special: footnote text/reference, endnote text/reference, header, footer, etc.
- Grid/List Table styles (Word 2013+)
- Annotation, Mention, Smart Hyperlink, etc. (Word 2016+)

Full list is in the Word-repaired output (see below for extraction).

## Required: default styles

At minimum, these default styles must be present:

```xml
<w:style w:type="paragraph" w:default="1" w:styleId="Normal">
  <w:name w:val="Normal"/>
  <w:qFormat/>
</w:style>

<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont">
  <w:name w:val="Default Paragraph Font"/>
  <w:uiPriority w:val="1"/>
  <w:semiHidden/>
  <w:unhideWhenUsed/>
</w:style>

<w:style w:type="table" w:default="1" w:styleId="TableNormal">
  <w:name w:val="Normal Table"/>
  <w:uiPriority w:val="99"/>
  <w:semiHidden/>
  <w:unhideWhenUsed/>
  <w:tblPr>
    <w:tblInd w:w="0" w:type="dxa"/>
    <w:tblCellMar>
      <w:top w:w="0" w:type="dxa"/>
      <w:left w:w="108" w:type="dxa"/>
      <w:bottom w:w="0" w:type="dxa"/>
      <w:right w:w="108" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
</w:style>

<w:style w:type="numbering" w:default="1" w:styleId="NoList">
  <w:name w:val="No List"/>
  <w:uiPriority w:val="99"/>
  <w:semiHidden/>
  <w:unhideWhenUsed/>
</w:style>
```

### Missing namespaces

Also needs `r`, `w14`, `w15`, w16* namespace declarations and `mc:Ignorable`.

## Implementation

1. Create a "default styles" template (as a Ruby constant, YAML, or XML file) containing the complete Word default style set.
2. This template should be configurable per Word version (2013, 2016, 2019, 2021, 2024).
3. The `docDefaults` section should pull theme font names from the theme and locale from user profile.
4. The `latentStyles` section is mostly static -- use the Word 2024 default list.
5. User-defined styles (from html2doc or other sources) are added on top of the defaults.
6. Default styles (Normal, DefaultParagraphFont, TableNormal, NoList) must always be present.
