# 09 — lutaml-model memory retention: verify, document, upstream

Status: DONE
Priority: P3 (tracking/diagnosis — the fix is upstream)
Absorbs: none

## Context

lutaml-model retains ~1200 `Lutaml::Model::Serializable` objects per
MB of DOCX parsed (element_order references), so the full spec suite
grows past 8 GB and segfaults — AGENTS.md forbids bare
`bundle exec rspec` for this reason and `spec/spec_helper.rb` carries
an `element_order`-clearing after(:each) mitigation.

## Goal

- Reproduce against the current lutaml-model version and measure:
  retained objects/MB before and after the mitigation.
- File (or find) the upstream issue in lutaml-model with the
  reproduction; link it from AGENTS.md and spec_helper.
- If a cheap local fix exists (e.g. an official bulk
  `clear_parse_state!` API or weak-reference path in lutaml-model),
  adopt it and remove the spec-time workaround; otherwise document
  precisely why the workaround stays.

## Design constraints

- No spec weakening: the full suite must remain runnable the same
  way it is today (directory-by-directory) without the hook if the
  hook is removed.
- Outcome is documentation + measurement (+ optional upstream patch);
  no forced refactor of uniword around a third-party issue.

## Acceptance

- A written measurement (objects/MB, current gem version) in this
  item's completion notes.
- Upstream issue link recorded, or a local adopted fix with the
  workaround removed and the full-suite constraint re-verified.

## Completion notes

Completed 2026-07-19.

### Measurement (Ruby 3.4.8, lutaml-model 0.8.17, office365.docx round-trips)

| scenario | RSS after 100 load/save cycles |
| --- | --- |
| natural GC only (no clearing) | +35.1 MB (~0.35 MB/cycle) |
| spec_helper clearing (element_order nil per cycle) | +5.8 MB (~0.06 MB/cycle) |

Reachability check: `ObjectSpace.each_object
(Lutaml::Model::Serializable).count` is 0 after `GC.start` even with
no clearing — instances ARE GC-collectable; the problem is the size
and lifetime of retained parse graphs BETWEEN GC cycles (~6x larger
without eager clearing). That is why the after(:each) hook is both
effective (~6x RSS reduction) and necessary for full-suite viability
(6000+ examples × ~1 MB+/cycle would otherwise pass 8 GB RSS — the
documented segfault mode).

### Upstream

- Filed https://github.com/lutaml/lutaml-model/issues/734 with the
  reproduction and table — requesting an official per-instance
  `clear_parse_state!` / bulk parse-state release API. (No existing
  issue found for this retention; lutaml-model 0.8.17 has
  `GlobalRegister#clear_all_model_caches` but nothing per-instance.)
- Linked from `AGENTS.md` (suite-warning paragraph) and
  `spec/spec_helper.rb` (hook comment — remove the hook if the API
  lands).

### Decision

Keep the workaround, justified by data: the hook is cheap (one
ObjectSpace sweep per example), and there is no official alternative
today. No uniword-side refactor around a third-party issue; the
suite discipline (targeted directories, never bare rspec) stands
until #734 resolves.
