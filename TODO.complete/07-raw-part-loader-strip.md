# 07 — RawPartLoader junk filter

**Status:** COMPLETED
**Priority:** High (the actual fix)
**Depends on:** 02, 04, 05, 06

## Problem

`Docx::RawPartLoader#unclaimed_paths` returns every ZIP entry no
registry loader claims. That includes junk (no content type, OS
artifact). Junk flows through as `RawPart(content_type: nil)` and
breaks the save-time integrity gate.

## Solution

Split `unclaimed_paths` into two populations:

- **Preservable paths**: unclaimed AND not junk. Loaded as `RawPart`.
- **Junk paths**: unclaimed AND junk. In `:strip` mode, recorded on
  `package.stripped_parts` and skipped. In `:raise` mode, treated as
  preservable (existing behavior — IntegrityChecker raises OPC-005 at
  save).

```ruby
class RawPartLoader
  def load(context, _definition)
    preservable, junk = partition_paths(context)

    record_stripped(context, junk)
    return if preservable.empty?

    bytes = raw_bytes(context, preservable)
    preservable.each do |path|
      next unless bytes[path]

      context.package.raw_parts[path] = build_part(
        context.package, path, bytes[path]
      )
    end
  end

  private

  def partition_paths(context)
    classifier = build_classifier(context)
    mode = Uniword.configuration.on_noncompliant_content

    unclaimed = unclaimed_paths(context)
    return [unclaimed, []] if mode == :raise

    unclaimed.partition { |path| classifier.reason(path).nil? }
  end

  def record_stripped(context, junk)
    return if junk.empty?

    classifier = build_classifier(context)
    context.package.stripped_parts # ensure array exists
    junk.each do |path|
      context.package.add_stripped_part(path: path,
                                        reason: classifier.reason(path))
      log_strip(path, classifier.reason(path))
    end
  end

  def build_classifier(context)
    JunkClassifier.new(
      content_types: context.package.content_types,
      relationships_by_path: relationships_by_target(context),
    )
  end

  def relationships_by_target(context)
    # Reuse the existing referencing_relationship machinery to
    # precompute the set of paths referenced by any modelled rels.
    # Implemented as a hash { target_path => true } for O(1) lookup.
  end

  def log_strip(path, reason)
    return unless Uniword.configuration.log_save_fixes

    Uniword.logger&.info { "Stripped non-compliant part #{path} (#{reason})" }
  end
end
```

## Where the policy switch lives

`partition_paths` reads `Uniword.configuration.on_noncompliant_content`
at load time. The result is stable for a given load call — if the
caller flips the policy mid-load, the change takes effect on the next
load.

## Why partition, not filter-then-record

`Array#partition` is single-pass. We get preservable and junk in one
walk. Filtering twice would iterate twice.

## Reporting

- `package.stripped_parts` populated via `Package#add_stripped_part`
  (a method, not direct array mutation — gives Package a hook to
  validate or log).
- Logger emits at INFO when `log_save_fixes` is true. Same channel as
  reconciler fixes; matches user expectation.

## Spec

Update `spec/uniword/docx/package_raw_part_passthrough_spec.rb`:

- The existing octet-stream test (line 203-246) is replaced with:
  - Junk part `[trash]/0000.dat` is NOT in `package.raw_parts`
  - Junk part IS in `package.stripped_parts` with the right reason
  - Output ZIP does NOT contain `[trash]/0000.dat`
  - `package.to_zip_content(validate: true)` produces no OPC-005 issues

Add `spec/uniword/docx/raw_part_loader_policy_spec.rb`:

- In `:strip` mode, junk paths are stripped (default)
- In `:raise` mode, junk paths are preserved as RawPart(content_type: nil)
  and `to_zip_content(validate: true)` raises ValidationError with
  structured OPC-005 issues
- Legitimate unmodelled parts (`docProps/meta.xml`) are preserved in
  BOTH modes
