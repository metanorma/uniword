# 06. docProps/app.xml: Fill in extended properties

## Problem

Our output only has `<Company/>`. Word fills in many more fields:

```xml
<!-- OUR OUTPUT -->
<Properties xmlns="...extended-properties" xmlns:vt="...docPropsVTypes">
  <Company/>
</Properties>
```

```xml
<!-- WORD OUTPUT -->
<Properties xmlns="...extended-properties" xmlns:vt="...docPropsVTypes">
  <Template>Normal.dotm</Template>
  <TotalTime>0</TotalTime>
  <Pages>1</Pages>
  <Words>1</Words>
  <Characters>11</Characters>
  <Application>Microsoft Office Word</Application>
  <DocSecurity>0</DocSecurity>
  <Lines>1</Lines>
  <Paragraphs>1</Paragraphs>
  <ScaleCrop>false</ScaleCrop>
  <Company></Company>
  <LinksUpToDate>false</LinksUpToDate>
  <CharactersWithSpaces>11</CharactersWithSpaces>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>16.0000</AppVersion>
</Properties>
```

## Rule

All these fields must be present. Some can be auto-computed, others come from user profile.

### Auto-computed fields (repair rules):

| Field                  | Value                              | Notes                              |
|------------------------|------------------------------------|------------------------------------|
| `Template`             | `"Normal.dotm"`                    | Default template, configurable     |
| `TotalTime`            | `"0"`                              | Editing time in minutes            |
| `Pages`                | Computed from document             | Page count                         |
| `Words`                | Computed from document             | Word count                         |
| `Characters`           | Computed from document             | Character count (no spaces)        |
| `CharactersWithSpaces` | Computed from document             | Character count (with spaces)      |
| `Lines`                | Computed from document             | Line count                         |
| `Paragraphs`           | Computed from document             | Paragraph count                    |
| `Application`          | User-configurable                  | e.g. `"Microsoft Office Word"`     |
| `AppVersion`           | User-configurable                  | e.g. `"16.0000"`                   |
| `DocSecurity`          | `"0"`                              | 0=none, 1=passworded, etc.         |
| `ScaleCrop`            | `"false"`                          | Thumbnail scaling                  |
| `LinksUpToDate`        | `"false"`                          | Hyperlink status                   |
| `SharedDoc`            | `"false"`                          | Shared document flag               |
| `HyperlinksChanged`    | `"false"`                          | Hyperlink change flag              |
| `Company`              | From user profile                  | Organization name                  |

## Implementation

1. Add all these attributes to the `ExtendedProperties` (AppProperties) model.
2. Compute `Pages`, `Words`, `Characters`, `CharactersWithSpaces`, `Lines`, `Paragraphs` from document content.
3. Allow `Application`, `AppVersion`, `Company`, `Template` to be configurable via a "user profile" or "repair profile".
4. Provide sensible defaults for boolean/flag fields.
