# 09 — lutaml-model memory retention: verify, document, upstream

Status: PENDING
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
