# 12 — Tracked changes invisible: `w:ins`/`w:del` not modeled, review CLI inert, round-trip drops them

## Problem
Uniword advertises "perfect round-trip fidelity" and ships a full
`review` command group (changes / accept / reject / accept-all /
reject-all), but tracked changes were never modeled:

1. `Paragraph` maps no `w:ins`/`w:del` elements, so a parsed tracked
   insertion is silently DROPPED — `uniword convert tracked.docx
   out.docx` produces a document whose `<w:ins>` nodes are gone
   (verified: a DOCX with a genuine
   `<w:ins w:id="7" w:author="Alice">…` loses the element entirely).
2. `DocumentRoot#revisions` is a bare `attr_accessor` that no loader
   populates, so `ReviewManager#tracked_changes` always manufactures
   an empty `TrackedChanges`: `uniword review changes FILE` reports
   "No tracked changes found" for real Word documents, and
   accept/reject/accept-all/reject-all operate on nothing (no-ops
   that report success).
3. `Uniword::Revision` (the facade object) serializes only the
   `<w:ins>` attribute shell (id/author/date) with a hardcoded
   `element "ins"` — no runs, no `<w:del>` — so it cannot round-trip
   real revisions either.

Deletion text has the same problem: `<w:del><w:r><w:delText>` — Run
maps `delText` (singular) but no container models the `w:del` node.

## Fix
- New models `Wordprocessingml::Insertion` and
  `Wordprocessingml::Deletion` (CT_RunTrackChange: `id`/`author`/
  `date` attributes + wrapped `runs` collection), following the
  established wrapped-runs pattern of `Hyperlink`.
- `Paragraph` gains `insertions`/`deletions` collections mapped to
  `w:ins`/`w:del` (mixed content preserves position via
  element_order) — round-trip fidelity restored.
- `Paragraph#text` now reads runs and insertion runs in element
  order (insertions are live content); deletion runs stay excluded
  (deleted content).
- `FindReplace::Scope` enumerates insertion runs alongside
  paragraph runs, so find-replace/redact cover text inside tracked
  insertions; deletion runs are left untouched.
- New `Review::RevisionResolver`: walks parsed ins/del nodes
  (via ParagraphWalker), hydrates the `TrackedChanges` facade with
  `Revision` entries (id = `w:id`), and applies decisions to the
  document models:
  - accept insert → splice runs into the paragraph (element_order
    `ins` entry replaced by `r` entries)
  - reject insert → remove the node
  - accept delete → remove the node
  - reject delete → splice runs back, converting `delText` to `t`
    (run element_order updated)
  `ReviewManager` wires the resolver into accept/reject/accept-all/
  reject-all; the facade list stays in sync.

## Status
IMPLEMENTED — lib/uniword/wordprocessingml/insertion.rb,
deletion.rb, paragraph.rb, find_replace/scope.rb,
review/revision_resolver.rb, review/review_manager.rb; specs:
spec/uniword/wordprocessingml/insertion_spec.rb,
spec/uniword/review/revision_resolver_spec.rb,
spec/uniword/cli_tracked_changes_spec.rb (end-to-end Open3:
changes → accept/reject → verified by reload).
