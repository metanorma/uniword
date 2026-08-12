# 18 — Reduce spec doubles

**Status:** Items 1-3 done. Item 4 outstanding. Count went 59 → 30 (29
addressed). Both contract defects are fixed: `ImageAltTextRule` now reads
`wp:docPr/@descr`, and `WordCss` now speaks `Wordprocessingml::Style`'s
real API (`id`, `font_family`, `alignment.value`, plus a new `Style#italic`).

What remains, by file:

| file | sites | why |
| --- | --- | --- |
| `spec/uniword/math_equation_spec.rb` | 10 (7 `double`, 3 `class_double`) | Plurimath — out of scope |
| `spec/uniword/math/plurimath_adapter_spec.rb` | 7 | Plurimath — out of scope |
| `spec/uniword/accessibility/rules_integration_spec.rb` | 5 | table/heading rules — item 4 |
| `spec/uniword/accessibility/accessibility_checker_spec.rb` | 2 (1 `double`, 1 `instance_double`) | item 4 |
| 6 single-site files | 6 | item 4, fold in opportunistically |

**Priority:** Medium for the spec cleanup; the two contract repairs below are
correctness fixes.
**Files:** see the work items below.

## Status of the original note

Stale. It claimed 69 sites. Actual today, counting all RSpec double
constructs: **59** — 55 plain `double(...)`, 3 `class_double`, 1
`instance_double`. Its named worst offenders are no longer the worst.
Distribution of plain doubles:

| file | sites |
| --- | --- |
| `spec/uniword/mhtml/word_css_spec.rb` | 14 |
| `spec/uniword/accessibility/rules/image_alt_text_rule_spec.rb` | 12 |
| `spec/uniword/math_equation_spec.rb` | 7 |
| `spec/uniword/math/plurimath_adapter_spec.rb` | 7 |
| `spec/uniword/accessibility/rules_integration_spec.rb` | 7 |
| `spec/uniword/accessibility/accessibility_checker_spec.rb` | 2 (+1 `instance_double`) |
| 6 other files | 1 each |

The original fix section also said to use `Struct` for data-only
doubles. `CLAUDE.md` says never use `Struct` or `OpenStruct`. Follow
CLAUDE.md; this note predates the rule. Two `Struct.new` sites already
exist in `spec/` — either violations to clean up or a rule needing a
written exception. Do not add a third.

## Problem

The doubles are not lazy tests. Two of them are hiding broken production
code, and that has to be fixed before the cleanup can even run.

### `ImageAltTextRule` crashes on any real document with an image

```
document.images               => [Uniword::Wordprocessingml::Drawing]
Drawing responds to alt_text? => false
rule.check(doc)               => NoMethodError:
                                 undefined method 'alt_text' for
                                 an instance of Wordprocessingml::Drawing
```

`DocumentRoot#images` (`document_root.rb:299`) is documented
`@return [Array<Drawing>]`. `ImageAltTextRule#check` calls
`image.alt_text` (`image_alt_text_rule.rb:21`). `alt_text` exists only on
`Uniword::Image` (`image.rb:28`), a different flat model that `#images`
never returns. The 12 doubles inject `alt_text` and paper over the crash.

### `WordCss` expects an API the real objects do not have

The doubles invent `style_id`, `font` and `italic`. Real
`Wordprocessingml::Style` exposes `id` (`style.rb:130`) and
`font_family` (`style.rb:200`), and has no `italic` reader.
`Mhtml::StylesConfiguration#styles` is declared
`attribute :styles, :hash` (`styles_configuration.rb:15`), not an
enumerable of style objects.

So "replace the double with a real instance" cannot be done for these
two without fixing production first.

## 1. Repair the accessibility contract (prerequisite)

Decide what `ImageAltTextRule` operates on. Most likely real OOXML
drawings, reading the description off `wp:docPr/@descr`, not a phantom
`alt_text` on `Drawing`. Then replace the 12 doubles in
`image_alt_text_rule_spec.rb` and the dependent doubles in
`rules_integration_spec.rb` and `accessibility_checker_spec.rb`.

Regression test must be a parsed document containing a real drawing, and
must fail before the fix.

## 2. Repair the WordCss contract (prerequisite)

Decide whether `WordCss` consumes WordprocessingML styles or MHTML style
hashes, then make the code and the type agree. Replace the 7 style-side
doubles (5 `Style`, 2 `StylesConfiguration`).

The namespace is **not** ambiguous, despite two classes sharing the name:
`word_css.rb:36` does `styles_config.styles.map` and then calls style-object
methods, while `Mhtml::StylesConfiguration#styles` is a plain `:hash` of CSS
properties. So `WordCss` consumes the **WordprocessingML** configuration. State
that as the contract.

The real work is adapting `WordCss` to `Wordprocessingml::Style`'s actual API:
it exposes `id` (`style.rb:130`) and `font_family` (`style.rb:200`), has a
wrapper-backed `alignment`, and has no `italic` reader at all — whereas the
doubles invent `style_id`, `font` and `italic`.

## 3. WordCss numbering doubles

The other 7 doubles in that file are 5 `NumberingInstance` and 2
`NumberingConfiguration`.

**This is independent of item 2 and can be done on its own.** `word_css.rb:50` calls
`numbering_config.instances`, and only `Wordprocessingml::NumberingConfiguration`
declares `instances` (`numbering_configuration.rb:16`); the MHTML one does not.
So the namespace is settled by the call itself, and a real
`NumberingConfiguration` plus `NumberingInstance` drops straight in.

Two earlier revisions got this wrong in both directions — first calling it
unblocked without checking, then calling it blocked on a namespace ambiguity
that does not exist. The call site resolves it.

## 4. The remaining doubles

Whatever is left after items 1-3, largest file first, one file per PR.
For each double: name the real class, construct it the way production
does, keep the assertion on observable behavior rather than call counts.

If a model turns out to be awkward to construct, that awkwardness is a
finding about the model's API. Record it. Do not paper over it with
another double.

## Verification

- Per file: `bundle exec rspec <file>` green **and proven able to fail**.
  Break the behavior under test once and watch it go red. Given what items
  1 and 2 uncovered, a green double-free spec that cannot fail is the
  main risk here.
- The count drops from 59 by the number actually addressed. Count all three
  constructs (`double`, `class_double`, `instance_double`), not just plain
  `double(` — an earlier revision of this note undercounted by missing
  `class_double`. **Do not state a target of zero.** List what remains
  explicitly.
- `bundle exec rubocop <touched files>`

## Out of scope

- `plurimath_adapter_spec.rb` and the Plurimath parts of
  `math_equation_spec.rb` (14 sites). These stand in for an external
  gem, so replacing them is a dependency-contract question, not spec
  hygiene. Needs `/dependency-contract-check` against Plurimath first.
  Should become its own TODO.
- The 6 single-site files. Fold in only if the file is already open for
  another reason.

## Expected outcome, stated honestly

This will not reduce the count much on its own. Its real output is the two
contract defects in items 1 and 2.

Severity differs between them. `ImageAltTextRule` is reachable and crashes on a
real document. `WordCss.generate_style_css` / `generate_list_css` have **no
caller under `lib/`** — only their specs call them — so they are broken public
helpers rather than a demonstrated downstream failure. Fix both, but do not
describe WordCss as a live production bug.
