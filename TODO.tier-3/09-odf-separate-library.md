# 09 — ODF interop (separate library)

**Status:** PLANNED (separate repo, not in uniword)
**Priority:** Strategic
**Depends on:** uniword's model patterns

## Why this is in TODO.tier-3 but NOT in uniword

ODF (ISO/IEC 26300, OpenDocument Format) is a different file format
family from OOXML (ECMA-376). Different element names, different
namespaces, different packaging (ZIP but different structure).
Wrapping ODF in uniword would muddy the architecture.

The right move is a **sibling library** — `uniword-odf` or
`ooffice-odf` — that:
- Shares uniword's design patterns (model-driven, lutaml-model,
  builder API, reconciler, verifier)
- Has its own ODF schema and element classes
- Imports/exports between ODF and OOXML where semantics align

## What that library would do

- Read/write `.odt`, `.ods`, `.odp`
- Round-trip with `LibreOffice` and `OpenOffice`
- Convert ODF ↔ OOXML via shared semantic model
- Open EU government market (regulations favor ODF)

## Where it lives

Likely `Ribose/uniword-odf` or `metanorma/uniword-odf`. Not started
yet — listed here so it's known as the strategic direction for ODF.

## Why defer

ODF is its own engineering investment (multi-month). Better to
solidify OOXML support first (Tier 1+2) before expanding formats.
