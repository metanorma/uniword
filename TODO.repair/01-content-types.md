# 01. [Content_Types].xml: Remove extra Default entries

## Problem

Our output includes image-related `<Default>` entries that Word does NOT include:

```xml
<!-- OUR OUTPUT (wrong) -->
<Default Extension="png" ContentType="image/png"/>
<Default Extension="jpeg" ContentType="image/jpeg"/>
<Default Extension="jpg" ContentType="image/jpeg"/>
<Default Extension="gif" ContentType="image/gif"/>
<Default Extension="bmp" ContentType="image/bmp"/>
<Default Extension="tif" ContentType="image/tiff"/>
<Default Extension="tiff" ContentType="image/tiff"/>
<Default Extension="svg" ContentType="image/svg+xml"/>
```

Word only includes the minimal required defaults:

```xml
<!-- WORD OUTPUT (correct) -->
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
```

## Rule

- Only include `<Default>` entries for `rels` and `xml` unless the document actually contains images of those types.
- Only include `<Override>` entries for parts that actually exist in the package.
- If the document contains images, then add `<Default>` entries only for the image types actually present.
- The `<Override>` for `word/theme/theme1.xml` must be present when a theme file exists.

## Implementation

In `PackageSerialization`, when building `[Content_Types].xml`:
1. Start with only `rels` and `xml` defaults.
2. Scan `image_parts` (or `word/media/`) for actual image extensions present and add `<Default>` entries only for those.
3. Only add `<Override>` entries for parts that are actually present in the package.
