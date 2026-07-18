# 02 — Write-time package integrity gate

Status: DONE
Priority: P0
Depends on: 01 (configuration)
Absorbs: none (new)

## Context

Every save funnels through `Docx::Package#to_zip_content`
(`lib/uniword/docx/package.rb:459-480`): defaults → `Reconciler#reconcile` →
`inject_part_relationships` → `serialize_package_parts` → `ZipPackager`.
Nothing in the path can refuse output; the Reconciler repairs but never
rejects. Equivalent checks exist only post-hoc on on-disk files
(`OpcValidator` OPC-005/006/008 in `lib/uniword/validation/opc_validator.rb`;
rules DOC-052/106/108). `Uniword::ValidationError` (`lib/uniword/errors.rb`)
is never raised.

## Goal

New `Uniword::Docx::PackageIntegrityChecker` (pure, non-mutating; MECE with
the mutating Reconciler), invoked in `to_zip_content` after
reconcile + inject, before `ZipPackager`. Checks on the in-memory content
hash + rels:

1. Every ZIP entry has a content type (Default by extension or Override).
2. Every relationship target (package rels and every part `.rels`) resolves
   to an entry present in the package.
3. Every `r:id` / `r:embed` / `r:link` referenced in any XML part exists in
   that part's `.rels` (generic, all parts — not just document.xml).
4. rIds unique within every `.rels` part (not only document rels).
5. Every emitted XML part is well-formed (Nokogiri strict re-parse).

Failure raises `Uniword::ValidationError` extended to carry a list of
structured issues (code, part path, message) — same shape the verify report
uses. Escape hatch: `save(path, validate: false)` threaded
`DocumentRoot#save`/`#to_file` → `DocumentWriter` → `Package.to_file`; default
from `Uniword.configuration.validate_on_save`. Apply the same gate in
`Ooxml::DotxPackage.to_file`; for `Mhtml::MhtmlPackage` apply what is
meaningful (not a ZIP) or document why not.

## Design constraints

- One issue-collector pass; open/closed: one public `check` returning
  `Issue` value objects, one private method per invariant.
- Do not call the zip-file-based `OpcValidator`; share issue-code semantics
  (OPC-005/006 style codes) where they match.
- Do not edit `lib/uniword.rb` (another work item owns it this wave) —
  register the new class via autoload in `lib/uniword/docx.rb` if present,
  else note it in completion notes for the coordinator.

## Acceptance

- Saving a doc with dangling `r:embed`, missing content type, duplicate
  rId, or unresolvable rel target raises `ValidationError` listing the
  issue(s); default saves of normal docs (builder docs, fixture round-trips)
  pass unchanged.
- Specs per invariant + through `DocumentRoot#save`; escape-hatch spec.
- `bundle exec rspec spec/uniword/docx/ spec/uniword/builder/` green.

## Completion notes

Completed 2026-07-18 (02/03 wave landed together).

### What was built

- `lib/uniword/docx/package_integrity_checker.rb` (NEW): pure,
  non-mutating `Docx::PackageIntegrityChecker`. One public `check`
  returning `Validation::Report::ValidationIssue` value objects; one
  private method per invariant. Codes: OPC-005 (content-type coverage),
  OPC-006 (rel target existence), OPC-008 (XML well-formedness,
  Nokogiri strict re-parse), OPC-009 (r:id/r:embed/r:link resolution,
  all XML parts), OPC-010 (rId uniqueness per .rels). Shares code
  semantics with the post-hoc `OpcValidator`; does not call it.
- Gate wired in `Docx::Package#to_zip_content` after reconcile + inject,
  before `ZipPackager` (`lib/uniword/docx/package.rb`
  `enforce_package_integrity`); same gate in `Ooxml::DotxPackage`
  (instance method there). `Mhtml::MhtmlPackage` not gated — MIME, not
  an OPC/ZIP package; documented in `DocumentWriter#save` YARD.
- `Uniword::ValidationError` extended with `issues:` (structured list),
  keeping the existing message form (`lib/uniword/errors.rb`).
- Escape hatch threaded: `DocumentRoot#save`/`#to_file` →
  `DocumentWriter#save`/`#write_to_stream` → `Docx::Package.to_file`
  (class + instance) / `DotxPackage.to_file`; default from
  `Uniword.configuration.validate_on_save` (item 01).
- Class registered via autoload in `lib/uniword/docx.rb` (the
  `lib/uniword.rb` constraint in the task text was respected during the
  wave).

### Dangling relationship targets (R32 repair, added this wave)

`spec/integration/round_trip_validation_spec.rb` (fixture
`no_styles.docx`) failed against the new gate: the fixture's
`word/_rels/document.xml.rels` carries a customXml relationship to
`../docProps/meta.xml`, a part uniword does not model — the loader drops
the part but Group 3 preserves the non-standard rel, so the gate
(correctly) rejected the output. General raw passthrough of unmodelled
parts is TODO.validate/08/09 territory (part registry); this wave
instead extends the 03 repair philosophy one level: new Group 4 pass
`reconcile_relationship_targets` (reconciler/referential_integrity.rb)
strips internal relationships whose resolved target is not among the
parts the save path emits, across package/document/settings/theme rels,
recorded as fix `R32`
(`FixCodes::DANGLING_RELATIONSHIP_TARGET_REMOVED`). External and
fragment (`#…`) targets are never stripped. `carried_part_paths`
mirrors `serialize_package_parts` emission; it moves to the part
registry when 08/09 land.

Two `reconciler_spec.rb` examples encoded the old contract ("preserve
non-standard rels" unconditionally); updated so their rel targets are
carried parts (custom-properties model / image part), preserving the
Group-3 intent under the new contract.

### Verification

- Specs per invariant (`package_integrity_checker_spec.rb`), through
  `DocumentRoot#save` incl. escape hatch + stream writes
  (`package_save_gate_spec.rb`), `DotxPackage` gate
  (`ooxml/dotx_package_spec.rb`), `ValidationError#issues`
  (`errors_spec.rb`).
- `bundle exec rspec spec/uniword/docx/ spec/uniword/builder/` — 810
  examples, 0 failures. (`id_allocator_spec.rb:70` initially failed:
  stale expectation of 12-char hex IDs after HEAD's deliberate "ID
  lengths" change to the OOXML-correct 8 — verified on a clean HEAD
  worktree that the failure predates this wave; spec updated to the
  8-char contract.)
- `spec/integration/round_trip_validation_spec.rb` +
  `spec/integration/repair_spec.rb` — 64 examples, 0 failures.
- RuboCop: no new offenses in touched lib files (remaining offenses in
  reconciler files are pre-existing Metrics/LineLength).
- CHANGELOG entry added under Unreleased ("Write-Time Validation and
  Reconciler Transparency").
