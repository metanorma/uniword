# TODO Index

Active work items for Uniword and related lutaml-model optimizations.

## Projects

| # | File | Status | Description |
|---|------|--------|-------------|
| 1 | [perf-optimizations.md](perf-optimizations.md) | In progress | 16 remaining lutaml-model deserialization optimizations |
| 2 | [shared-validation-gem.md](shared-validation-gem.md) | Not started | Extract `Lutaml::Validation` shared gem from uniword + svg_conform |

## Priority Order

1. **perf-optimizations** (items 1-4) -- High impact, reduces ISO doc deserialization from ~20s toward ~10s
2. **shared-validation-gem** -- Extract after perf work stabilizes; large refactoring across 3 repos

## Completed (removed)

- **TODO.iso-round-trips** -- All done. ISO 8601, ISO 690, ISO DIS 5878 pass with 0 normative differences.
- **TODO.uniword-resources** -- All 21 phases done. Font registry, 30 locales, loaders, mapping, auto-transition, CLI commands, tests, docs.
- **TODO.perf** (11 of 27 done) -- Optimizations 00, 01, 03, 05, 06, 08, 09, 10, 11, 12, 23 applied.
