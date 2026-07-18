# 11 — Validation engine consolidation (one engine, two front-ends)

Status: PENDING
Priority: P2 (structural)
Depends on: 02 (gate reuses verification semantics)
Absorbs: none (deletes dead code)

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
