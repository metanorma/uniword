# 11. word/theme/theme1.xml: Add theme file

## Problem

Our output has no theme file at all. Word always adds `word/theme/theme1.xml` during repair.

## Rule

Every DOCX must contain a theme file at `word/theme/theme1.xml`. The theme defines:
1. Color scheme (12 colors: dk1, lt1, dk2, lt2, accent1-6, hlink, folHlink)
2. Font scheme (major + minor font with per-script font assignments)
3. Format scheme (fill, line, effect, background styles)

A minimal theme file looks like:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office">
  <a:themeElements>
    <a:clrScheme name="Office">
      <a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1>
      <a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1>
      <a:dk2><a:srgbClr val="44546A"/></a:dk2>
      <a:lt2><a:srgbClr val="E7E6E6"/></a:lt2>
      <a:accent1><a:srgbClr val="4472C4"/></a:accent1>
      <a:accent2><a:srgbClr val="ED7D31"/></a:accent2>
      <a:accent3><a:srgbClr val="A5A5A5"/></a:accent3>
      <a:accent4><a:srgbClr val="FFC000"/></a:accent4>
      <a:accent5><a:srgbClr val="5B9BD5"/></a:accent5>
      <a:accent6><a:srgbClr val="70AD47"/></a:accent6>
      <a:hlink><a:srgbClr val="0563C1"/></a:hlink>
      <a:folHlink><a:srgbClr val="954F72"/></a:folHlink>
    </a:clrScheme>
    <a:fontScheme name="Office">
      <a:majorFont>
        <a:latin typeface="Aptos Display" panose="020B0004020202020204"/>
        <a:ea typeface=""/>
        <a:cs typeface=""/>
        <!-- per-script font entries -->
      </a:majorFont>
      <a:minorFont>
        <a:latin typeface="Aptos" panose="020B0004020202020204"/>
        <a:ea typeface=""/>
        <a:cs typeface=""/>
        <!-- per-script font entries -->
      </a:minorFont>
    </a:fontScheme>
    <a:fmtScheme name="Office">
      <!-- fill, line, effect, background styles -->
    </a:fmtScheme>
  </a:themeElements>
  <a:objectDefaults/>
  <a:extraClrSchemeLst/>
  <a:extLst>
    <a:ext uri="{05A4C25C-085E-4340-85A3-A5531E510DB2}">
      <thm15:themeFamily xmlns:thm15="http://schemas.microsoft.com/office/thememl/2012/main"
        name="Office" id="{37A524BA-ABC4-4F37-99CC-4253A94629F8}"
        vid="{1E1B1C36-3BD8-4F6D-876C-D2A3A5C1B46C}"/>
    </a:ext>
  </a:extLst>
</a:theme>
```

### Key points:

1. Theme name and color scheme are configurable via "user profile" or "repair profile"
2. Font scheme must match the fonts used in `docDefaults` in `styles.xml`
3. The `thm15:themeFamily` extension is required by Word 2013+
4. The `thm15:` attributes (`name`, `id`, `vid`) must be UNQUALIFIED (no namespace prefix) -- see fixed `attribute_form_default :unqualified` on ThemeML namespace
5. The theme GUIDs (`id`, `vid`) should be generated once and kept stable

### Relationships needed:

In `word/_rels/document.xml.rels`:
```xml
<Relationship Id="rId5"
  Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme"
  Target="theme/theme1.xml"/>
```

In `[Content_Types].xml`:
```xml
<Override PartName="/word/theme/theme1.xml"
  ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
```

## Implementation

1. Create built-in theme templates (Office 2013/2016/2019/2024 default themes).
2. Allow user-configurable themes (load from DOTX template or custom theme XML).
3. The theme must be serialized to `word/theme/theme1.xml` during save.
4. Add the theme relationship to `document.xml.rels` and content type override.
5. The theme font names feed into `docDefaults` in `styles.xml`.
