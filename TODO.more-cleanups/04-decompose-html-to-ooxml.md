# 04: Decompose HtmlToOoxmlConverter (535 lines)

**Priority:** P2
**Effort:** Medium (~4 hours)
**File:** `lib/uniword/transformation/html_to_ooxml_converter.rb`

## Problem

`HtmlToOoxmlConverter` is 535 lines — the same god-class pattern as
`OoxmlToMhtmlConverter` (now 253 lines after decomposition into 3 modules).

It likely mixes HTML parsing, element mapping, and OOXML construction.

## Fix

Apply the same decomposition pattern used for OoxmlToMhtmlConverter:

```
lib/uniword/transformation/
  html_to_ooxml_converter.rb       # Coordinator (~150 lines)
  html_element_parser.rb           # HTML → intermediate representation (~200 lines)
  ooxml_element_builder.rb         # Intermediate → OOXML model construction (~200 lines)
```

Keep the public API identical: `HtmlToOoxmlConverter.convert(html)`.

The existing `HtmlImporter` class (referenced in `Uniword.from_html`) may
already handle some of this. Check for overlap before decomposing.

## Verification

```bash
bundle exec rspec spec/uniword/transformation/
bundle exec rspec spec/integration/mhtml_round_trip_spec.rb
```
