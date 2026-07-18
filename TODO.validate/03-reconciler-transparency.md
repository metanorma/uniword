# 03 — Reconciler transparency and behavioral unification

Status: DONE
Priority: P0
Depends on: 01 (configuration); lands together with 02 (same files)
Absorbs: none (new)

## Context

`lib/uniword/docx/reconciler.rb` + `reconciler/*` run on every save but never
reject. Problems:

- `@applied_fixes` (reconciler.rb:85-91) is discarded after save.
- Allocator path (Builder, and every `Package.from_file` round-trip via
  `populate_allocator`) only LOGS warnings for dangling note/hyperlink refs
  (`reconciler/referential_integrity.rb:34-53`) while the legacy path strips
  them — divergent outcomes for identical input.
- `reconcile_image_references` (:279-304) only *counts* dangling `r:embed`
  rIds and writes them anyway.
- `Reconciler::FixCodes::R10` is overloaded across ~8 concerns
  (`reconciler/fix_codes.rb:15-17`).

## Goal

1. Expose the reconciliation report: `Package#applied_fixes` (value objects:
   code, message, part) populated on save; log each fix via `Uniword.logger`
   when `Uniword.configuration.log_save_fixes`.
2. Unify allocator/legacy: dangling note/hyperlink/style/numbering refs are
   repaired (stripped) on both paths, or left for the 02 gate to reject —
   pick repair-by-stripping for consistency; no warn-only divergence.
3. `reconcile_image_references` must actually repair: remove drawings whose
   `r:embed` has no matching image relationship (consistent with other
   referential repairs), recording the fix.
4. Split `R10` into one fix code per concern (open/closed, self-describing
   codes); update all call sites and specs referencing R10.

## Design constraints

- Reconciler stays the only mutating pass; the report is a by-product value,
  not a global.
- No forbidden constructs; autoload rules apply to any new file.

## Acceptance

- Specs: fixes observable on the package after save; identical document
  saved via builder path vs legacy path yields identical referential
  outcome; dangling image refs absent from saved output; valid docs produce
  zero fixes.
- `bundle exec rspec spec/uniword/docx/` green (incl. reconciler specs).

## Completion notes

Completed 2026-07-18 (02/03 wave landed together).

### What was built

1. **Reconciliation report** — `Reconciler::Fix` value object
   (`reconciler/fix.rb`: code, message, part). `record_fix` now builds
   `Fix` instances; `Package#applied_fixes` exposes the reconciler's
   report after each save and is reset per save. Each fix is logged via
   `Uniword.logger` when `Uniword.configuration.log_save_fixes`
   (`Package#log_applied_fixes`). All `record_fix` call sites updated to
   pass meaningful `part:` values.
2. **Allocator/legacy unification** — `reconcile_referential_integrity`
   no longer branches: the warn-only `validate_note_references` /
   `validate_hyperlink_references` allocator-path methods are deleted
   (along with their `DANGLING_*_WARNING` codes); both paths run the
   same repair-by-stripping passes. Identical input now yields
   identical referential outcome.
3. **Image reference repair** — `reconcile_image_references` removes
   drawings whose `r:embed` rIds all dangle (R23), keeping shape-only
   drawings and drawings with at least one resolving embed.
4. **Fix code split** — the overloaded R10 (and shared R4/R11/R12/R13)
   concerns now have one self-describing code each: R17–R31
   (referential repairs, style/table/run cleanup, hyperlink promotion).
   Historic wire codes R1–R16 are frozen for the original concerns
   (external rules pattern-match on them); uniqueness enforced by
   `fix_codes_spec.rb`.
5. **Dangling relationship targets (this wave's addition)** — new
   `reconcile_relationship_targets` pass strips rels to un-emitted
   parts (R32); see 02 completion notes for rationale.

### Verification

- `spec/uniword/docx/reconciler/referential_integrity_spec.rb` (NEW):
  builder vs legacy paths produce identical repairs; image repair keep/
  remove cases; relationship-target strip/keep cases; valid docs yield
  zero referential repairs.
- `spec/uniword/docx/package_save_gate_spec.rb` (NEW): fixes observable
  on the package after save; dangling image refs absent from reloaded
  output; logging on/off.
- `spec/uniword/docx/reconciler/fix_codes_spec.rb` (NEW): one unique
  code per concern; frozen historic codes.
- `spec/uniword/docx/` + `spec/uniword/builder/` green (see 02 notes
  for the stale `id_allocator_spec.rb:70` expectation fixed en route).
