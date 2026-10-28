# 03 — Native PDF writer

**Status:** PLANNED (Tier 3)
**Priority:** Strategic bet
**Depends on:** nothing

## Why

Eliminates the LibreOffice dep. Puts uniword in the same league as
docx4j + Apache PDFBox, or python-docx + reportlab. Pure-Ruby PDF
generation from the OOXML model.

## Approach

Three options:
1. Wrap `prawn` (mature Ruby PDF library) — fast to ship, limited
   fidelity for complex OOXML
2. Build native renderer from scratch — high fidelity, multi-month
3. Use `pdfkit` or similar via C bindings — fast, native-dep

## Why Tier 3

Multi-month effort. Better as a separate gem (`uniword-pdf-native`)
so users who don't need PDF don't pay the dep cost.

## When to promote

When LibreOffice bridge limits become painful (font fidelity,
performance, deployment size).
