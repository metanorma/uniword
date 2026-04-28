# Bug 07: settings.xml default values differ from Word's canonical form

## Severity: FIXED

## Summary

The Reconciler's default values now match Word's canonical output.

## What was fixed

### 1. Math margins — FIXED
```xml
<m:lMargin m:val="0"/>
<m:rMargin m:val="0"/>
```

### 2. w14:docId format — FIXED
Short hex format: `SecureRandom.hex(4).upcase`

### 3. Missing elements — FIXED
- `w:doNotDisplayPageBoundaries` — added
- `w:useFELayout` — added to `<w:compat>`

### 4. Extra element — NOT CHANGED
- `w15:chartTrackingRefBased` — preserved from source documents on round-trip (not stripped)

### 5. useWord2013TrackBottomHyphenation value — FIXED
```xml
val="0"
```
