# 04 — Wire the HTML output the CLI already advertises

## Problem
`convert`'s help says "Supported formats: DOCX, MHTML, HTML" but
`DocumentWriter#save` has no `:html` case and `infer_format` raises for
`.html` — `uniword convert x.docx out.html` fails. The converter exists
(`Transformation::OoxmlToHtmlConverter.document_to_html`) and HTML
*input* is already supported (`DocumentFactory` `when :html` →
`Uniword.from_html`).

## Fix
- `DocumentWriter#infer_format`: `.html`/`.htm` → `:html`
- `DocumentWriter#save`: `when :html` →
  `OoxmlToHtmlConverter.document_to_html(document)` written to path
  (or stdout via #05)

## Status
IMPLEMENTED — lib/uniword/document_writer.rb;
spec: spec/uniword/cli/html_output_spec.rb (content + extension
round-trip via CLI).
