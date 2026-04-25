# 09. word/fontTable.xml: Populate with user-profile fonts

## Problem

Our output is empty:

```xml
<!-- OUR OUTPUT -->
<w:fonts xmlns:mc="..." xmlns:w="..."/>
```

Word adds a set of fonts based on the user's system/profile:

```xml
<!-- WORD OUTPUT -->
<w:fonts xmlns:mc="..." xmlns:r="..." xmlns:w="..." xmlns:w14="..." xmlns:w15="..."
  xmlns:w16cex="..." xmlns:w16cid="..." xmlns:w16="..." xmlns:w16du="..."
  xmlns:w16sdtdh="..." xmlns:w16sdtfl="..." xmlns:w16se="..."
  mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du">

  <w:font w:name="Aptos">
    <w:panose1 w:val="020B0004020202020204"/>
    <w:charset w:val="00"/>
    <w:family w:val="swiss"/>
    <w:pitch w:val="variable"/>
    <w:sig w:usb0="20000287" w:usb1="00000003" w:usb2="00000000" w:usb3="00000000"
           w:csb0="0000019F" w:csb1="00000000"/>
  </w:font>

  <w:font w:name="DengXian">
    <w:altName w:val="等线"/>
    <w:panose1 w:val="02010600030101010101"/>
    <w:charset w:val="86"/>
    <w:family w:val="auto"/>
    <w:pitch w:val="variable"/>
    <w:sig w:usb0="A00002BF" w:usb1="38CF7CFA" w:usb2="00000016" w:usb3="00000000"
           w:csb0="0004000F" w:csb1="00000000"/>
  </w:font>

  <w:font w:name="Times New Roman">
    <w:panose1 w:val="02020603050405020304"/>
    <w:charset w:val="00"/>
    <w:family w:val="roman"/>
    <w:pitch w:val="variable"/>
    <w:sig w:usb0="E0002EFF" w:usb1="C000785B" w:usb2="00000009" w:usb3="00000000"
           w:csb0="000001FF" w:csb1="00000000"/>
  </w:font>

  <w:font w:name="DengXian Light">
    <w:altName w:val="等线 Light"/>
    <w:panose1 w:val="02010600030101010101"/>
    <w:charset w:val="86"/>
    <w:family w:val="auto"/>
    <w:pitch w:val="variable"/>
    <w:sig w:usb0="A00002BF" w:usb1="38CF7CFA" w:usb2="00000016" w:usb3="00000000"
           w:csb0="0004000F" w:csb1="00000000"/>
  </w:font>

  <w:font w:name="Aptos Display">
    <w:panose1 w:val="020B0004020202020204"/>
    <w:charset w:val="00"/>
    <w:family w:val="swiss"/>
    <w:pitch w:val="variable"/>
    <w:sig w:usb0="20000287" w:usb1="00000003" w:usb2="00000000" w:usb3="00000000"
           w:csb0="0000019F" w:csb1="00000000"/>
  </w:font>
</w:fonts>
```

## Rule

The font table must include:
1. **Body text font** (e.g., `Aptos` in Word 2024, `Calibri` in earlier versions)
2. **Heading/display font** (e.g., `Aptos Display`)
3. **East Asian font** (e.g., `DengXian`, `MS Gothic` -- depends on locale)
4. **Legacy serif font** (`Times New Roman` -- always present)

The exact font list depends on:
- Word version
- User locale (determines East Asian font)
- Theme (determines body/heading font)

### Font entry structure

Each font entry requires:
- `w:name` - Font name
- `w:panose1` - PANOSE classification (10-digit hex)
- `w:charset` - Character set (`00`=Western, `86`=GB2312)
- `w:family` - Font family (`swiss`, `roman`, `auto`)
- `w:pitch` - Pitch (`variable`, `fixed`)
- `w:sig` - Font signature (usb0-3, csb0-1)
- Optional `w:altName` - Alternative name (for CJK fonts)

### Missing namespaces

The `fontTable.xml` also needs the w16* namespace declarations and `mc:Ignorable`.

## Implementation

1. Define a "font profile" concept that specifies default fonts for a given locale/Word version.
2. Provide built-in profiles:
   - Word 2024 (Aptos + Aptos Display + locale CJK + Times New Roman)
   - Word 2016-2021 (Calibri + Calibri Light + locale CJK + Times New Roman)
3. Allow user-customizable font profiles.
4. Auto-detect which fonts are actually used in the document and include only those + defaults.
5. Include the full namespace declarations on the root element.
