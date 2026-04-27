# 01: Fix duplicate namespace class definitions

**Priority:** P0 (bug)
**Effort:** Small (~30 min)
**File:** `lib/uniword/ooxml/namespaces.rb`

## Problem

Four namespace classes are defined twice in the same file, with the second
definition silently overriding the first. This can cause subtle bugs if code
references the class before the override or if the definitions diverge.

## Duplicates

| Class | First definition | Second definition |
|-------|-----------------|-------------------|
| `WordProcessingDrawing` | Line 28 | Line 60 |
| `Relationships` | Line 79 | Line 174 |
| `VML` | Line 88 | Line 294 (as `Vml`) |
| `CustomXml` | Line 270 | Line 278 |

Note: `VML` (line 88) and `Vml` (line 294) are technically different Ruby
constants (case-sensitive) but represent the same XML namespace
`urn:schemas-microsoft-com:vml` with the same prefix `v`. Both should be
consolidated into one.

## Fix

For each duplicate pair:
1. Keep the first definition (lower line number)
2. Delete the second definition
3. Find all references to both names and unify them
4. For `VML`/`Vml`, pick one name (`VML` is more conventional for XML namespace
   constants) and update all references

```bash
# Find all references
grep -rn 'VML\b\|Vml\b' lib/ spec/
grep -rn 'WordProcessingDrawing' lib/ spec/
grep -rn 'Relationships' lib/ spec/
grep -rn 'CustomXml' lib/ spec/
```

## Verification

```bash
bundle exec rspec
# All 4400+ tests must pass with no namespace-related failures
```
