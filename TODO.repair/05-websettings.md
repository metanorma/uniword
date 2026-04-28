# 05. word/webSettings.xml: Add namespace declarations and mc:Ignorable

## Problem

Our output is missing namespace declarations:

```xml
<!-- OUR OUTPUT -->
<w:webSettings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
```

```xml
<!-- WORD OUTPUT -->
<w:webSettings
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
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
  mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du"/>
```

## Rule

Word validates against the presence of these namespace declarations. They must all be present.

Required namespaces:
- `mc` (Markup Compatibility)
- `r` (Relationships)
- `w` (WordProcessingML)
- `w14` (Word 2010)
- `w15` (Word 2012)
- `w16cex` (Word 2018 cex)
- `w16cid` (Word 2016 cid)
- `w16` (Word 2018)
- `w16du` (Word 2023 du)
- `w16sdtdh` (Word 2020 sdt data hash)
- `w16sdtfl` (Word 2024 sdt format lock)
- `w16se` (Word 2015 symex)

With `mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du"`.

## Implementation

Add these namespaces to the `WebSettings` model's `namespace_scope` and set `mc:Ignorable` attribute.
