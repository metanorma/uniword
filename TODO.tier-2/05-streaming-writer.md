# 05 — Streaming writer for huge documents

**Status:** PLANNED
**Priority:** High for enterprise (1000+ page documents)
**Depends on:** Tier 1 lutaml-model leak fix

## Why

Currently loads the entire model into memory before writing. A
1000-page document is millions of nodes; materializing all of them
just to serialize is wasteful and OOM-prone. A SAX-style writer
would let uniword handle documents of any size.

## Scope

- New `Uniword::Docx::StreamingWriter` that emits XML as it walks
  the model, without building intermediate content hash
- Cooperative with reconciler (reconcile per-section, not per-doc)
- Compatible with existing reader (round-trip works)
- Opt-in via `doc.save(path, streaming: true)`

## Out of scope

- Streaming reader (lutaml-model limitation; needs upstream fix)
- Cross-document streaming (multiple docs in one stream)
