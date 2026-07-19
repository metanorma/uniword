# 06 — MCE-aware XSD preprocessing (noise-free schema validation)

Status: PENDING
Priority: P1
Absorbs: the 10 pendings documented in TODO.validate/07's completion
notes (inherited-error fixtures + full-validity-including-MCE)

## Context

`uniword verify --xsd` reports dozens of "errors" on every real
document because `XmlSchemaValidator` validates raw parts including
MCE extension content (mc:Ignorable attributes, w14:paraId/textId,
w14/w15/w16 elements) that the bundled transitional XSDs do not
declare — genuine Word output fails identically. The corpus spec
(TODO.validate/07) classifies these as MCE-attributable and hard-fails
only on non-MCE errors; full validity is tracked by 10 pendings.

## Goal

- A preprocessor in `XmlSchemaValidator`: before validating a
  WordprocessingML part, strip content that is MCE-ignorable per the
  part's own `mc:Ignorable` declaration — attributes and elements in
  the declared-ignorable namespaces (mc:Ignorable attribute itself,
  w14:* extension attributes/elements it names, and their subtrees).
- Validate the stripped document against the XSD. Genuine Word output
  (and uniword output) then validates clean modulo real errors.
- Un-pend the 10 corpus pendings whose root cause is MCE content
  (keep the inherited-fixture-content ones that are genuine
  pre-existing invalidity — reclassify per actual cause).

## Design constraints

- Semantically driven: read each part's own mc:Ignorable declaration;
  do not hard-code namespace lists (the current corpus
  MCE_NAMESPACE_PREFIXES heuristic is the thing this replaces).
- Preprocessing must not mutate the package or the validator's input;
  work on a parsed copy.
- Same forbidden-construct and autoload rules.
- Offline only (no schema fetching).

## Acceptance

- `uniword verify --xsd` on uniword-generated documents reports zero
  MCE-attributable findings; genuine errors still surface.
- Corpus spec: the MCE full-validity pending is removed and passes;
  each inherited-error pending is re-triaged (kept with cause or
  fixed).
- `bundle exec rspec spec/uniword/validation/
  spec/integration/xsd_output_validation_spec.rb
  spec/integration/round_trip_validation_spec.rb` green.
