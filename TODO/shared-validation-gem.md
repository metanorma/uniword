# Lutaml::Validation -- Shared Validation Framework

## Status: Not Started

## Problem

Three lutaml-ecosystem projects independently implement validation with nearly
identical patterns:

| Project | Rule base | Registry | Report model | Profiles | Remediation |
|---------|-----------|----------|-------------|----------|-------------|
| svg_conform | `BaseRequirement` | filesystem scan + YAML | `ValidationIssue` + `ConformanceReport` | YAML composable, import | built-in, linked to rules |
| uniword | `Rules::Base` | explicit `register()` | `ValidationIssue` + `VerificationReport` | none | separate `Docx::Reconciler` |
| lutaml-model | `Validator` + `ValidationRule` | DSL inline | exception hierarchy | none | none |

## Proposal

Extract a shared `lutaml-validation` gem (or `Lutaml::Validation` module within
lutaml-model) providing:

1. **Issue** -- shared issue model (severity, code, message, location, suggestion)
2. **Report / LayerResult** -- shared report models, serializable via lutaml-model
3. **Context** -- base validation context with error accumulation and per-rule state
4. **Rule** -- abstract base class contract (code, category, severity, applicable?, check)
5. **Registry** -- supports both explicit registration and filesystem auto-discovery
6. **Profile** -- YAML composable profiles with import, parameterized rules
7. **Remediation** -- fix pipeline linked to requirements

Domain-specific code (DOCX ZIP access, SVG SAX parsing) stays in each project.

## Dependency Graph

```
Phase 1: Issue model
  |
  v
Phase 2: Report models (LayerResult, Report)
  |
  v
Phase 3: Context base
  |
  v
Phase 4: Rule base class
  |
  v
Phase 5: Registry
  |
  +---> Phase 6: Profiles (also needs lutaml-model polymorphic)
  |
  +---> Phase 7: Remediation
  |
  v
Phase 8: Integration with lutaml-model errors
  |
  v
Phase 9: Adoption guides (svg_conform + uniword)
```

## Key Design Decisions

- **Issue** is a `Lutaml::Model::Serializable` subclass (serializes to JSON/YAML)
- **Rule** is a plain Ruby class (not Serializable); domain projects subclass it
- **Context** supports both return-array style (uniword) and imperative accumulate style (svg_conform)
- **Registry** is instance-based (not module methods) for multiple registries to coexist
- **Profile** selects *which* rules run, not *how* they run; domain projects extend for per-rule config
- **Remediation** uses code-string targeting (`targets: ["DOC-020"]`) for loose coupling
- **lutaml-model integration** is opt-in via `validate(issue_mode: true)` -- zero breaking changes

## Proposed API Sketches

### Issue

```ruby
class Issue < Lutaml::Model::Serializable
  attribute :severity, :string        # "error", "warning", "info", "notice"
  attribute :code, :string            # "DOC-020", "SVG-001"
  attribute :message, :string
  attribute :location, :string        # file path, part name, XPath
  attribute :line, :integer
  attribute :suggestion, :string
  attribute :metadata, :string        # JSON-serialized hash
  def error?   = severity == "error"
  def warning? = severity == "warning"
  def info?    = severity == "info"
end
```

### Rule

```ruby
class Rule
  def code = nil                      # override in subclass
  def category = :general
  def severity = "error"
  def applicable?(_context) = true    # skip predicate
  def check(_context) = []            # returns Array<Issue>
  def needs_deferred? = false         # for streaming validation
  def collect(_element, _context); end
  def complete(_context) = []
end
```

### Registry

```ruby
class Registry
  def register(rule_class); end       # explicit (uniword style)
  def auto_discover(dir, pattern:); end  # filesystem scan (svg_conform style)
  def all; end                        # instantiate all registered rules
  def for_category(cat); end
  def find(code); end
end
```

### Profile (YAML)

```yaml
# config/profiles/basic.yml
name: basic
description: Basic DOCX validation
rules:
  - OpcValidator
  - StyleReferencesRule
  - FootnotesRule
```

```yaml
# config/profiles/strict.yml
name: strict
import:
  - basic
rules:
  - BookmarksRule
  - ImagesRule
  - TablesRule
```

### Remediation

```ruby
class Remediation
  def id = nil
  def targets = nil                   # nil = handle all; array of issue codes
  def applicable?(report); end
  def fix(context, report); end       # returns RemediationResult
  def preview(context, report); end   # dry-run, optional
end
```

## Key Files to Create

```
lib/lutaml/validation.rb
lib/lutaml/validation/issue.rb
lib/lutaml/validation/layer_result.rb
lib/lutaml/validation/report.rb
lib/lutaml/validation/context.rb
lib/lutaml/validation/rule.rb
lib/lutaml/validation/registry.rb
lib/lutaml/validation/profile.rb
lib/lutaml/validation/remediation.rb
lib/lutaml/validation/remediation_result.rb
```

## Uniword Adoption Plan

| Current | Becomes |
|---------|---------|
| `Rules::Base` | `class Base < Lutaml::Validation::Rule` |
| `Rules::Registry` | `Lutaml::Validation::Registry` instance |
| `DocumentContext` | `class DocumentContext < Lutaml::Validation::Context` |
| `Report::ValidationIssue` | `Lutaml::Validation::Issue` |
| `Report::LayerResult` | `class LayerResult < Lutaml::Validation::LayerResult` |
| `Report::VerificationReport` | `class VerificationReport < Lutaml::Validation::Report` |
| `Docx::Reconciler` | Optional: `Lutaml::Validation::Remediation` subclass |
| No profiles | Add basic/strict YAML profiles |

8 files to modify in uniword. Zero breaking changes to public API. Profile support is additive.

## Relationship to Existing lutaml-model Validation

**Orthogonal, not replacement.**

- **lutaml-model validation** (existing): validates model instance state
  (attribute types, ranges, patterns). Runs during deserialization.
- **lutaml-validation** (proposed): validates document-level concerns
  (structural integrity, cross-references, conformance). Runs on parsed
  documents against domain rules.

Phase 8 bridges them via `to_validation_issue` on error classes and opt-in
`validate(issue_mode: true)`.
