# 06 — Configuration#on_noncompliant_content

**Status:** COMPLETED
**Priority:** High (policy knob)
**Depends on:** nothing

## Problem

Default behavior should be Word-like (strip silently). Strict callers
need a way to opt into "raise on any non-compliance" so they can catch
issues programmatically. The policy needs to live in `Configuration`
for consistency with `validate_on_save`, `xsd_validation`,
`log_save_fixes`.

## Solution

Add a symbol-typed attribute mirroring the existing boolean pattern.

```ruby
class Configuration
  VALID_MODES = %i[strip raise].freeze

  attr_reader :on_noncompliant_content

  def reset!
    @validate_on_save = true
    @xsd_validation = false
    @log_save_fixes = true
    @on_noncompliant_content = :strip
    self
  end

  def on_noncompliant_content=(value)
    sym = value.to_sym
    unless VALID_MODES.include?(sym)
      raise ArgumentError,
            "on_noncompliant_content must be :strip or :raise, " \
            "got #{value.inspect}"
    end
    @on_noncompliant_content = sym
  end
end
```

## Why two modes, not three

The user's framing: "caller takes error as return, OR explicitly
requests strip". Two modes only:

- `:strip` (default) — auto-clean, populate stripped_parts, never raise
- `:raise` — preserve, let IntegrityChecker raise with structured issues

A third `:report` mode (strip + return issues list) would muddle the
API. Anyone wanting report-only can set `validate_on_save = false` and
call `Verification.verify(path)` separately.

## Per-call override?

For now: no. Configuration-level only. Per-call overrides add API
surface; if needed later, `doc.save(path, on_noncompliant: :raise)` is
additive.

## Default value

`:strip` — Word-identical behavior. Most users expect their saved DOCX
to look like Word wrote it, not to fail because of source junk.

## Spec

Extend `spec/uniword/configuration_spec.rb`:

- Default is `:strip`
- Setter accepts `:strip` and `:raise` (and string equivalents)
- Setter raises `ArgumentError` for invalid values
- `reset!` restores `:strip`
