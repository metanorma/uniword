# Tier 1 — High-ROI items (next quarter)

These four items together unlock the biggest audience and use-case
expansion. Each is independently shippable.

## Items

| # | Item | Impact | Effort |
|---|---|---|---|
| 01 | [lutaml-model memory leak](01-lutaml-model-memory-leak.md) | Unblocks large docs + server use | L (upstream + mitigation) |
| 02 | [find-replace](02-find-replace.md) | Closes ~half the perceived Word parity gap | M |
| 03 | [track-changes toggle + combine](03-track-changes-toggle-and-combine.md) | Review workflow completeness | S + L |
| 04 | [captions + cross-references + toc-figures](04-captions-cross-references-toc-figures.md) | Tech/science writing trifecta | M |

## What Tier 1 unlocks

- **Enterprise-ready**: leak fix means >10 MB DOCX files actually work.
- **ImageMagick-for-Word positioning**: `find-replace` is the literal
  equivalent of `convert` — every Word power user knows Find & Replace.
- **Review pipeline complete**: from authoring (toggle tracking on) →
  redlining (already accept/reject) → merge (combine).
- **Tech writing ready**: figure/table/equation numbering with
  cross-refs is table stakes for ISO/IEEE/ACM documents.

## What Tier 1 deliberately defers

- PDF export, HTTP API, Docker — moved to Tier 3.
- ODF — separate library ( Ribose `ooffice-odf` or similar).
- Mail merge, citations — Tier 2.
