# 020: DRY duplicate run-merging logic between builder and reconciler

## Status: DONE

## Problem

Run merging logic is duplicated between `ParagraphBuilder` and
`Reconciler::Helpers` with divergent behavior:

| Aspect | ParagraphBuilder (build-time) | Reconciler::Helpers (reconcile-time) |
|--------|-------------------------------|--------------------------------------|
| `empty_run?` | 5 checks (text, fn, en, tab, br) | 15 checks (all known non-text elements) |
| `text_only_run?` | 5 checks | 10 checks |
| `rpr_match?` | `to_xml` comparison | `to_xml` comparison |
| `merge_run_text` | Handles `xml_space` | Handles `xml_space` + extra elements |

The builder's `text_only_run?` only checks 5 element types. The reconciler's
checks 10. If a run has `position_tab`, `no_break_hyphen`, or `del_text`, the
builder treats it as mergeable but the reconciler doesn't. This divergence is
a correctness risk.

Additionally, `empty_run?` has the same divergence — the builder version is
much simpler than the reconciler's.

### DRY principle violation

Both modules implement the same conceptual operations independently:

- `ParagraphBuilder#mergeable?` ≈ `Helpers#can_merge? + run_properties_match?`
- `ParagraphBuilder#text_only_run?` ≈ `Helpers#text_only_run?` (incomplete)
- `ParagraphBuilder#rpr_match?` = `Helpers#run_properties_match?`
- `ParagraphBuilder#merge_run_text` ≈ `Helpers#merge_run_into`
- `ParagraphBuilder#empty_run?` ≈ `Helpers#empty_run?` (incomplete)

## Fix

Extract shared run utilities into a dedicated module:

```ruby
module Uniword
  module Builder
    module RunUtils
      def self.text_only_run?(run)
        # Complete, canonical check (from reconciler)
      end

      def self.empty_run?(run)
        # Complete, canonical check (from reconciler)
      end

      def self.properties_match?(a, b)
        # Shared rPr comparison
      end

      def self.merge_text(target, source)
        # Shared text merging with xml_space handling
      end
    end
  end
end
```

Both `ParagraphBuilder` and `Reconciler::Helpers` delegate to `RunUtils`.
This ensures identical behavior at build-time and reconcile-time.

## Files
- `lib/uniword/builder/paragraph_builder.rb` (lines 174-244)
- `lib/uniword/docx/reconciler/helpers.rb` (lines 122-301)
