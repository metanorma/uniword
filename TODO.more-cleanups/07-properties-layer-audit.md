# 07: Audit properties/ layer (51 files, 1837 lines) vs Builder API

**Priority:** P2
**Effort:** Medium (~3 hours)
**Files:** `lib/uniword/properties/` (51 files)

## Problem

The `properties/` directory contains 51 wrapper classes (1837 lines total). Per
CLAUDE.md, wrapper objects should NOT be exposed in the public API — the Builder
pattern is the correct API surface.

Some of these 51 files may be:
- Dead code that was superseded by Builder convenience methods
- Value objects that are actually used as lutaml-model types (e.g., `ColorValue`,
  `StyleReference`) — these are legitimate
- Wrapper objects that duplicate what Builder already provides

## Known Legitimate Properties

These are lutaml-model value types used in XML mapping:
- `color_value.rb` — `ColorValue` used in attribute declarations
- `relationship_id.rb` — `RelationshipId` for r:id references
- `numbering_id.rb` / `numbering_properties.rb` — numbering references

## Audit Approach

1. For each properties file, grep for references outside `properties/`:
   ```bash
   for f in lib/uniword/properties/*.rb; do
     klass=$(basename "$f" .rb | camelize)
     count=$(grep -r "$klass" lib/ --include='*.rb' | grep -v "properties/" | wc -l)
     echo "$count $klass"
   done | sort -n
   ```
2. Files with 0 external references are dead code — remove them
3. Files referenced only by Builder may be candidates for merging into Builder
4. Files referenced by model classes are legitimate value types

## Verification

```bash
bundle exec rspec
```
