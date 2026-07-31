# 02 — Citations / CSL

**Status:** PLANNED
**Priority:** High for academic users
**Depends on:** nothing (citeproc-ruby gem exists)

## Why

Academic users hit this immediately. Bibliography is partially
modeled; need full CSL/BibTeX integration.

## Scope

- Read CSL-JSON or BibTeX bibliography
- Insert citations as fields that bind to entries
- Generate bibliography section with CSL-rendered output
- Support citation styles: APA, MLA, Chicago, IEEE, ISO 690

## CLI

```
uniword citations insert FILE --source refs.bib --key smith2024 --style apa
uniword citations bibliography FILE --source refs.bib --style iso690 --output refs.docx
```

## Ruby API

```ruby
doc.add_citation(key: "smith2024", source: "refs.bib", style: "apa")
doc.generate_bibliography(source: "refs.bib", style: "iso690")
```

## Architecture

Wraps `citeproc-ruby` for CSL rendering. Citation fields use existing
OOXML field infrastructure. Bibliography is a generated section.

## Out of scope

- Live citation graph (Zotero/Mendeley integration)
- Reference managers via plugin (Tier 2 plugin system)
