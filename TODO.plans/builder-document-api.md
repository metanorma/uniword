# Plan: Fix Builder and Document API Wrapper Issues

## Status: PARTIALLY FIXED

### Style Property - FIXED ✓
Changed `attribute :style, Properties::StyleReference` to `attribute :style, :string` with `map_attribute 'val', to: :style`. This works correctly:
- `para.properties.style` returns `"Heading1"` (String)
- XML serializes to `<pStyle w:val="Heading1"/>` correctly

### Boolean Properties (italic, bold) - ARCHITECTURAL ISSUE

Tests like `expect(para.runs.first.properties.italic).to be true` fail because:
- `italic` returns `Italic` wrapper object (for correct OOXML serialization)
- Test expects boolean `true`

**Root Cause**: OOXML boolean elements like `<w:i/>` require wrapper classes for correct serialization:
- `<w:i/>` (no val attr) = true
- `<w:i w:val="false"/>` = false

The wrapper handles this semantic. Without wrappers, we can't serialize correctly.

## Fundamental Conflict

| Requirement | Can It Be Met? |
|------------|---------------|
| Correct OOXML serialization | YES (requires wrappers) |
| No wrappers in public API | NO (wrappers needed for booleans) |
| No custom getters | NO (would need `italic?` or `== true` override) |

**Decision Needed**: Accept boolean properties return wrappers, OR change tests to use predicate methods like `italic?`

## Affected Specs

- `spec/uniword/builder_spec.rb` - ✓ FIXED (18/18 passing)
- `spec/uniword/document_spec.rb` - 1 failure remains (italic)
