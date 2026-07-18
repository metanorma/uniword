# 01 — Global configuration object

Status: DONE
Priority: P0 (foundation for 02/03/07)
Absorbs: none (new)

## Context

There is no global configuration object. `lib/uniword/configuration/` contains
only `ConfigurationLoader` (a YAML-file reader). Save-path policy (validate on
save, XSD validation, fix reporting) currently has no home — only ad-hoc
kwargs (`VerifyOrchestrator.new(xsd_validation: true)`).

## Goal

- `Uniword::Configuration` class + `Uniword.configuration` (memoized) +
  `Uniword.configure { |config| ... }` module methods in `lib/uniword.rb`.
- Attributes (defaults): `validate_on_save: true`, `xsd_validation: false`,
  `log_save_fixes: true`. Plain typed attributes with readers/writers — no
  Struct/OpenStruct, no OpenStruct-style arbitrary keys (closed, explicit).
- Reconcile namespace with the existing `ConfigurationLoader` (inspect
  `lib/uniword/configuration.rb` / `lib/uniword.rb` autoloads first; keep the
  loader working and its specs green).

## Design constraints

- Autoload registration in the immediate parent namespace file; no
  `require_relative`/`require` for in-library code.
- This object is runtime policy only — do not turn it into a god object.

## Acceptance

- `Uniword.configure` yields the config; defaults as above; resettable for
  specs (e.g. a `#reset!` or fresh-instance helper used by specs).
- `spec/uniword/configuration_spec.rb` (or mirrored path) covers defaults,
  writer round-trip, and `configure` block.
- No forbidden constructs (`send`/`public_send`/`respond_to?`/
  `instance_variable_*`/`require_relative`).


## Completion notes

Implemented 2026-07-18.

Files changed:

- `lib/uniword/configuration.rb` — `Uniword::Configuration` converted from
  module to class (a class still serves as the `ConfigurationLoader`/
  `ConfigurationError` namespace and supports `autoload`). Added typed
  boolean attributes with the specified defaults:
  `validate_on_save: true`, `xsd_validation: false`, `log_save_fixes: true`.
  Readers via `attr_reader`; writers validate strict booleans and raise
  `ArgumentError` otherwise (closed, explicit — no arbitrary keys).
  `#reset!` restores defaults (used by specs). `ConfigurationLoader`
  autoload kept as-is.
- `lib/uniword/configuration/configuration_loader.rb` — reopening keyword
  changed `module Configuration` → `class Configuration` (only change;
  loader behavior untouched). Also wrapped two pre-existing >80-col comment
  lines flagged by rubocop.
- `lib/uniword.rb` — added `Uniword.configuration` (memoized) and
  `Uniword.configure { |config| ... }` (returns the config) to
  `class << self`. The `autoload :Configuration` line already existed
  (line 114) and was kept.
- `spec/uniword/configuration_spec.rb` — new; covers defaults, writer
  round-trips, non-boolean rejection, `#reset!`, `ConfigurationLoader`
  namespace reconciliation, `Uniword.configuration` memoization, and
  `Uniword.configure` yield/apply. Resets global config in an `after` hook.
- `TODO.validate/01-global-configuration.md` — this status update.

Verification:

- `bundle exec ruby -Ilib -e 'require "uniword"; puts
  Uniword.configuration.validate_on_save'` → `true`
- `bundle exec rspec spec/uniword/configuration_spec.rb` → 13 examples,
  0 failures
- Loader consumers still green: smoke (`configuration_smoke_spec`,
  `autoload_spec`), `quality/document_checker_spec`,
  `validation/link_validator_spec`, `validation/verify_orchestrator_spec`
  — combined run with the new spec: 110 examples, 0 failures.
- `bundle exec rubocop` on all four touched files → no offenses.

Deviations / notes for follow-up tasks (02/03/07):

- Writers are strictly boolean (`ArgumentError` on non-boolean) — set with
  `true`/`false` only, not truthy values.
- The config object is not yet consulted by any save path; wiring belongs
  to task 02.
- No `Uniword.reset_configuration!` was added; specs use
  `Uniword.configuration.reset!`.
