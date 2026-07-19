# 06 — MCE-aware XSD preprocessing (noise-free schema validation)

Status: DONE
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

## Completion notes

Completed 2026-07-19.

### Design (and the element-strip reversal, with evidence)

`XmlSchemaValidator#preprocess_mce` runs before every XSD validation:
it reads the part's OWN `mc:Ignorable` declaration (semantically
driven — no hard-coded namespace lists), maps prefixes to namespace
URIs via the root's declarations, and strips ATTRIBUTES in those
namespaces (w14:paraId/textId et al.) plus the `mc:Ignorable`
attribute itself (undeclared on most root types in the transitional
XSDs).

Extension ELEMENTS are deliberately KEPT. The original plan stripped
them too, but evidence showed that changes libxml2's content-model
evaluation: with w14:docId/w15:docId present, a misplaced baseline
element (office365's `rsids`, placed late by Word) is tolerated via
CT_Settings' trailing `xsd:any`; with the docIds removed, the same
misplacement is exposed as a false baseline error. Verified
empirically: element-strip → 1 new false error on office365;
attribute-only strip → rsids error gone, only the w15 extension
element error remains (MCE-attributable by classification).

So the noise contract is two-layered: preprocessing kills the
attribute-level false errors (the bulk — w14:paraId/textId,
mc:Ignorable), and the corpus's MCE-attributable classifier (extension
namespaces) covers the remaining extension-ELEMENT findings — which
genuine Word output produces identically because the transitional
XSDs don't declare w14/w15 content.

### Outcomes

- `uniword verify --xsd` on uniword-generated documents: "All checks
  passed" (was 37 MCE-attributable errors on the smoke document).
- Corpus spec: the systemic full-validity PENDING is now a passing
  assertion — zero non-MCE XSD errors for the whole corpus. The 9
  inherited-error fixture pendings stay (genuine pre-existing content
  invalidity in the fixtures themselves: missing w:val on sz/szCs/kern,
  tblInd/proofState order, sig usb/csb attributes, minimal pgMar) —
  re-triaged and unchanged by preprocessing.
- New unit spec `spec/uniword/validation/validators/
  xml_schema_validator_spec.rb` (4 examples): paraId/textId stripped,
  mc:Ignorable stripped, no-op without declaration, genuine pgMar
  error still reported.
- `spec/uniword/validation/` + corpus + round_trip_validation: 341
  examples, 0 failures, 9 pending (the inherited set).
- RuboCop: validator unchanged (7=7); spec files within the
  integration-spec norm.
