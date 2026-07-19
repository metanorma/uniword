# 11 — Validation engine consolidation (one engine, two front-ends)

Status: DONE
Priority: P2 (structural)
Depends on: 02 (gate reuses verification semantics)
Absorbs: none (deletes dead code)

## Completion notes

### Dependency-graph findings (per deleted file)

All callers verified by grep before deletion:

- `validation/document_validator.rb` (`Validation::DocumentValidator`) —
  referenced only by itself, its autoload, and docs. No production caller.
- `validation/validators/{file_structure,zip_integrity,ooxml_part,
  relationship,content_type}_validator.rb` — referenced only by
  `DocumentValidator`. `VerifyOrchestrator` uses only
  `xml_schema_validator.rb` and `document_semantics_validator.rb`, which
  remain (both still subclass the kept `LayerValidator`).
- `lib/uniword/validators/` (`ElementValidator`/`ParagraphValidator`/
  `TableValidator` + `validators.rb`) — referenced only by themselves and
  their specs (`spec/uniword/validators/`, deleted alongside).
- `lib/uniword/warnings/` (`Warning`/`WarningCollector`/`WarningReport` +
  `warnings.rb`) — no callers at all; nothing needed migration into the
  verification report. Also deleted its orphaned smoke spec
  (`spec/uniword/smoke/warnings_smoke_spec.rb`) and the two namespace
  entries in `spec/uniword/smoke/autoload_spec.rb`.
- `config/validation_rules.yml` — loaded only by `DocumentValidator`.
  `config/warning_rules.yml` — loaded only by `WarningCollector`. Both
  deleted (`config/link_validation_rules.yml` stays: used by the kept
  `LinkValidator`).
- Autoloads cleaned in `lib/uniword.rb` (`Validators`, `Warnings`),
  `lib/uniword/validation.rb` (`DocumentValidator`, `StructuralValidator`;
  `Engine` added), and `validation/validators.rb` (5 dead layer
  validators).

### Engine design

- `Validation::Engine.run(context)` — the single engine. Filters
  registered rules by `rule.context_type == context.context_type`, then
  applies `applicable?`/`check`, returning
  `Array<Report::ValidationIssue>` (one result model).
- `Rules::Base#context_type` — new, defaults to `:package` (on-disk).
- `Rules::DocumentContext#context_type` — `:package` (post-save,
  unchanged behavior).
- `Rules::ModelContext` (new) — wraps a `DocumentRoot`; `#context_type`
  is `:model`, `#document` exposes the model (pre-save front-end).
- `Rules::ModelRule < Base` (new) — base for in-memory rules;
  `context_type` is `:model`.
- `Validators::DocumentSemanticsValidator` (verify layer 3) now calls
  `Engine.run` instead of its inline rule loop, so both front-ends share
  the one code path. Two spec-local inline rule loops
  (`spec/integration/round_trip_validation_spec.rb`,
  `spec/integration/repair_spec.rb`) were migrated to `Engine.run` too —
  they previously iterated `Registry.all` directly and broke on
  model rules.

### Rules migrated / added

StructuralValidator's 4 checks became model rules (same messages and
severities as before):

- DOC-200 `DocumentBodyRule` (error) — was `check_body_present`; also the
  new "document requires body" rule.
- DOC-201 `BookmarkPairingRule` (error) — was `check_bookmark_pairing`.
- DOC-202 `BookmarkUniquenessRule` (warning) — was
  `check_bookmark_uniqueness`.
- DOC-203 `EmptyParagraphsRule` (warning) — was `check_empty_paragraphs`.

New structural rules (grounded in wml.xsd CT_Tbl, which requires exactly
one `tblPr` and one `tblGrid`):

- DOC-204 `TableGridRule` (error) — `tbl` requires `tblGrid`.
- DOC-205 `TablePropertiesRule` (error) — `tbl` requires `tblPr`.

Registry now holds 26 rules (20 package + 6 model), registered in
`lib/uniword/validation/rules.rb`.

### API / behavior changes

- `DocumentRoot#valid?` / `#validation_errors` / `#validation_warnings`
  unchanged in signature; now powered by `Engine.run(ModelContext.new(doc))`
  (errors = error-severity issues, warnings = the rest).
- CLI `validate` runs the engine on the loaded in-memory model, prints
  `[CODE] message` lines, and exits 1 when error-severity issues exist
  (previously always exited 0). Warnings do not affect the exit code.
- Note: uniword's own save-time reconciler repairs `tblPr`/`tblGrid`, so
  a uniword-produced file will not trigger DOC-204/205 on reload; the
  rules bite on the in-memory model (pre-save) and on foreign files.

### Verification results

- `spec/uniword/validation/` + `spec/uniword/cli_spec.rb`: 200 examples,
  0 failures.
- `spec/integration/xsd_output_validation_spec.rb` +
  `round_trip_validation_spec.rb` + `repair_spec.rb`: 161 examples,
  0 failures, 28 pending.
- `spec/lint/` + `spec/uniword/wordprocessingml/`: 665 examples,
  0 failures.
- `spec/uniword/smoke/`: 1729 examples, 0 failures.
- `exe/uniword help` exits 0; `exe/uniword validate <valid>` exits 0;
  `exe/uniword validate <tbl-without-tblGrid>` prints DOC-204/DOC-205 and
  exits 1; acceptance one-liner prints `false` for a `DocumentRoot` with
  a `tblGrid`-less table.
- Forbidden-construct grep over `lib/`: zero hits.
- RuboCop: no new offenses in any touched file (cli/main.rb: 40 → 39).

## Context

Three validation systems coexist:
- `Validation::DocumentValidator` (7-layer,
  `lib/uniword/validation/document_validator.rb` +
  `lib/uniword/validation/validators/*` + `config/validation_rules.yml`) —
  no production caller; superseded by `VerifyOrchestrator` (which still
  uses `validators/xml_schema_validator.rb` and
  `validators/document_semantics_validator.rb` — check the real dependency
  graph before deleting).
- `Validation::VerifyOrchestrator` — live, CLI `verify`.
- `Validation::StructuralValidator` — in-memory, 4 checks, opt-in via
  `DocumentRoot#valid?` (`document_root.rb:233-249`).
- Dead: `lib/uniword/validators/` (ElementValidator/Paragraph/Table stubs)
  and `lib/uniword/warnings/` (WarningCollector — grep for callers first).
- CLI `validate` (`cli/main.rb:104`) runs only StructuralValidator and
  exits 0 even on issues.

## Goal

1. Delete `DocumentValidator` and any `validation/validators/*` files not
   used by `VerifyOrchestrator`; delete `lib/uniword/validators/` and
   `lib/uniword/warnings/` (migrate genuinely-used pieces into the
   verification report first); remove orphaned `config/validation_rules.yml`
   and all stale autoloads from `lib/uniword.rb`; delete or migrate their
   specs.
2. Fold StructuralValidator's in-memory checks into the rules engine as
   model-level rules (same `Rules::Registry`, in-memory front-end), and add
   bounded new structural rules: `tbl` requires `tblGrid`, `document`
   requires `body`, plus any required-children rule already documented in
   wml.xsd for the top complex types you touch. `DocumentRoot#valid?` /
   `#validation_errors` keep working, now powered by the engine.
3. CLI `validate` runs the same engine on the in-memory model and exits
   non-zero on errors (align with `verify`).

## Acceptance

- No dead validation code remains; one registry, one result model, two
  invocation times (pre-save in-memory, post-save on-disk).
- Specs: engine runs in-memory rules; `document.valid?` false for a table
  without tblGrid; `uniword validate` exit codes; surviving validation
  suites green (`spec/uniword/validation/` plus touched CLI specs).
- No forbidden constructs; autoload cleanup included.
