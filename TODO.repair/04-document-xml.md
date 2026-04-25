# 04. word/document.xml: Add tracking attributes and namespace declarations

## Problem

Our output is missing critical tracking attributes on `<w:p>` and `<w:sectPr>`, and missing many namespace declarations on `<w:document>`.

### Missing tracking attributes

```xml
<!-- OUR OUTPUT -->
<w:p>
  <w:r>
    <w:t>Hello World</w:t>
  </w:r>
</w:p>
<w:sectPr>
  ...
</w:sectPr>
```

```xml
<!-- WORD OUTPUT -->
<w:p w14:paraId="282EE091" w14:textId="77777777"
     w:rsidR="00AA6FE3" w:rsidRDefault="00000000">
  <w:pPr>
    <w:spacing w:before="320" w:after="0"/>
  </w:pPr>
  <w:r>
    <w:t>Hello World</w:t>
  </w:r>
</w:p>
<w:sectPr w:rsidR="00AA6FE3">
  ...
</w:sectPr>
```

### Missing namespace declarations on `<w:document>`

Word declares all these namespaces on the root `<w:document>` element:

```xml
<w:document
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex"
  xmlns:cx1="http://schemas.microsoft.com/office/drawing/2015/9/8/chartex"
  xmlns:cx2="http://schemas.microsoft.com/office/drawing/2015/10/21/chartex"
  xmlns:cx3="http://schemas.microsoft.com/office/drawing/2016/5/9/chartex"
  xmlns:cx4="http://schemas.microsoft.com/office/drawing/2016/5/10/chartex"
  xmlns:cx5="http://schemas.microsoft.com/office/drawing/2016/5/11/chartex"
  xmlns:cx6="http://schemas.microsoft.com/office/drawing/2016/5/12/chartex"
  xmlns:cx7="http://schemas.microsoft.com/office/drawing/2016/5/13/chartex"
  xmlns:cx8="http://schemas.microsoft.com/office/drawing/2016/5/14/chartex"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:aink="http://schemas.microsoft.com/office/drawing/2016/ink"
  xmlns:am3d="http://schemas.microsoft.com/office/drawing/2017/model3d"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:oel="http://schemas.microsoft.com/office/2019/extlst"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
  xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
  xmlns:w16cex="http://schemas.microsoft.com/office/word/2018/wordml/cex"
  xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid"
  xmlns:w16="http://schemas.microsoft.com/office/word/2018/wordml"
  xmlns:w16du="http://schemas.microsoft.com/office/word/2023/wordml/word16du"
  xmlns:w16sdtdh="http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash"
  xmlns:w16sdtfl="http://schemas.microsoft.com/office/word/2024/wordml/sdtformatlock"
  xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du wp14">
```

Our output only declares: `w`, `r`, `mc`.

## Required tracking attributes

### On every `<w:p>` (Paragraph):

| Attribute  | Namespace | Description                          | Auto-generated value           |
|------------|-----------|--------------------------------------|-------------------------------|
| `w14:paraId` | w14     | Unique paragraph ID (8 hex chars)    | Random hex, e.g. `"282EE091"` |
| `w14:textId` | w14     | Text content change ID               | `"77777777"` for new content  |
| `w:rsidR`    | w       | Revision save ID for paragraph start  | From rsids table              |
| `w:rsidRDefault` | w   | Default revision ID for runs          | From rsids table              |

### On `<w:sectPr>` (Section Properties):

| Attribute  | Description                    |
|------------|--------------------------------|
| `w:rsidR`  | Revision save ID for section   |

## Required namespaces on `<w:document>`

These namespaces must be declared via `namespace_scope` on the `DocumentRoot` model. The full list (Word 2024 era) is:

```
wpc, cx, cx1-cx8, mc, aink, am3d, o, oel, r, m, v, wp14, wp, w10,
w, w14, w15, w16cex, w16cid, w16, w16du, w16sdtdh, w16sdtfl, w16se,
wpg, wpi, wne, wps
```

With `mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du wp14"`.

## Implementation

1. **rsid tracking**: Generate a revision save ID on each save operation. Store in `w:rsids` in `settings.xml`. Apply to paragraphs and section properties.

2. **paraId/textId**: Auto-generate `w14:paraId` as random 8-hex-char string. Set `w14:textId` to `"77777777"` for new content (Word uses this sentinel for "new text").

3. **Namespace declarations**: Add all the above namespaces to the `DocumentRoot` model's `namespace_scope`. Add `mc:Ignorable` attribute.
