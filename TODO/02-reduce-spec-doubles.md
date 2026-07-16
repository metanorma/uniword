# 18 — Reduce spec doubles (69 sites)

**Priority:** Medium (spec quality)
**Files:** Multiple spec files, worst offenders:
- `spec/uniword/accessibility/rules/image_alt_text_rule_spec.rb` (~20)
- `spec/uniword/accessibility/rules_integration_spec.rb` (~10)
- `spec/uniword/accessibility/accessibility_checker_spec.rb` (~7)
- `spec/uniword/math_equation_spec.rb` (~6)

## Problem

Project rule: never use `double()` in specs. Use real model instances or
`Struct.new(...).new(...)` for plain data.

69 `double()` callsites across spec/. Worst offenders use doubles to
mock out complex model behavior, which means the tests verify that
methods are called rather than that the actual behavior is correct.

## Fix

For each spec:
1. Identify what the double is mocking
2. Replace with a real model instance constructed with the required
   attributes
3. If the model is hard to set up, build a small test factory
4. Verify the test still asserts the same observable behavior

For data-only doubles (no behavior), use `Struct`:
```ruby
# Before
let(:doc) { double("Doc", paragraphs: [...]) }

# After
DocumentStub = Struct.new(:paragraphs)
let(:doc) { DocumentStub.new([...]) }
```

For doubles that mock method calls, refactor the test to assert on
observable output (return values, side effects) rather than on
method-call counts.

## Verification

`grep -rn "double(" spec/uniword/ | wc -l` should trend toward 0.
Tests pass.
