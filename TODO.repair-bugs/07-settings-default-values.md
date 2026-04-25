# Bug 07: settings.xml default values differ from Word's canonical form

## Severity: Low
Word accepts the values we produce. Differences are cosmetic but deviate from Word's canonical output.

## Summary

The Reconciler's `build_math_pr` and `reconcile_settings` use default values that differ from what Word produces.

## Differences

### 1. Math margins
```xml
<!-- Ours -->
<m:lMargin m:val="1440"/>
<m:rMargin m:val="1440"/>

<!-- Word -->
<m:lMargin m:val="0"/>
<m:rMargin m:val="0"/>
```
`lib/uniword/docx/reconciler.rb:551-552`: `LMargin.new(val: "1440")` and `RMargin.new(val: "1440")`

### 2. w14:docId format
```xml
<!-- Ours (GUID format) -->
<w14:docId w14:val="{8783CA24-FA24-49F3-9ABE-D3DA8BDF0A89}"/>

<!-- Word (short hex format) -->
<w14:docId w14:val="0DFBF0C3"/>
```
`lib/uniword/docx/reconciler.rb:196-198`: Uses `SecureRandom.uuid.upcase` wrapped in `{}`

### 3. Missing elements
- `w:doNotDisplayPageBoundaries` — present in Word output, not in ours
- `w:useFELayout` — present in Word output (inside `<w:compat>`), not in ours

### 4. Extra element
- `w15:chartTrackingRefBased` — present in ours, not in Word's repair output

### 5. useWord2013TrackBottomHyphenation value
```xml
<!-- Ours -->
<w:compatSetting w:name="useWord2013TrackBottomHyphenation" ... w:val="1"/>

<!-- Word -->
<w:compatSetting w:name="useWord2013TrackBottomHyphenation" ... w:val="0"/>
```
`lib/uniword/docx/reconciler.rb:528`: `val: "1"` — should be `"0"` for default

## Fix

Update defaults in reconciler to match Word's canonical output:

```ruby
# In build_math_pr
lMargin: Wordprocessingml::LMargin.new(val: "0"),
rMargin: Wordprocessingml::RMargin.new(val: "0"),

# In reconcile_settings
settings.w14_doc_id ||= Wordprocessingml::W14DocId.new(
  val: SecureRandom.hex(4).upcase  # short hex, not GUID
)

# Add missing elements
settings.do_not_display_page_boundaries ||= ...
settings.use_fe_layout ||= ...  # inside compat

# Fix default value
Wordprocessingml::CompatSetting.new(
  name: "useWord2013TrackBottomHyphenation",
  uri: "http://schemas.microsoft.com/office/word",
  val: "0"  # not "1"
)

# Consider removing chartTrackingRefBased for simple documents
```
