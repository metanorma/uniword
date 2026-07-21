# 08 — Revert octet-stream fallback

**Status:** COMPLETED
**Priority:** High (correctness)
**Depends on:** 07 (RawPartLoader strips at load, so save path no
longer sees nil content types)

## Problem

`d9d766b5` (commit on this branch) added a fallback that injected
`<Override ContentType="application/octet-stream">` for any raw part
with a nil content type, so that 1.4.0's integrity gate would pass.

This is the wrong fix:

- It preserves junk that Word would strip (output larger than Word's).
- It masks genuinely missing declarations instead of surfacing them.
- It puts load-path policy in the save path (wrong layer).

Once 07 lands (strip at load), the save path no longer encounters
nil-content-type raw parts in the default policy. The fallback is dead
code.

## Solution

In `lib/uniword/docx/package_serialization.rb`:

1. Remove the `FALLBACK_RAW_PART_CONTENT_TYPE` constant.
2. Restore the original guard: `next unless part.path && part.content_type`.
3. Remove the comment block introducing the fallback.

```ruby
# Before
FALLBACK_RAW_PART_CONTENT_TYPE = "application/octet-stream"

def inject_raw_part_content_types(content_types)
  return if raw_parts.empty?

  raw_parts.each_value do |part|
    next unless part.path
    # ... uses part.content_type || FALLBACK_RAW_PART_CONTENT_TYPE
  end
end

# After
def inject_raw_part_content_types(content_types)
  return if raw_parts.empty?

  raw_parts.each_value do |part|
    next unless part.path && part.content_type
    # ... uses part.content_type only
  end
end
```

## What about programmatically-created RawParts?

A user who creates a `RawPart` via the API without setting
`content_type` is making a programmer error. The save should fail
loudly. With the fallback removed, OPC-005 fires for that part and
`ValidationError` is raised.

This is the correct behavior — fail fast on programmer error, silently
clean Word-side junk.

## Spec

The existing octet-stream test in
`spec/uniword/docx/package_raw_part_passthrough_spec.rb` (lines 203-246)
is updated to assert strip behavior instead. See TODO.complete/07.
