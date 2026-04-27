# 06: Add 12_math.yml to schema_loader pipeline

**Priority:** P1
**Effort:** Small (~2 hours including testing)
**Files:**
- `config/ooxml/schema_loader.yml` (add entry)
- `config/ooxml/schemas/12_math.yml` (verify contents)
- Generated math classes (verify they load correctly)

## Problem

`config/ooxml/schemas/12_math.yml` exists as a file but is NOT listed in
`schema_loader.yml`'s `schema_files:` array. The list jumps from
`11_drawing.yml` directly to `13_charts.yml`:

```yaml
schema_files:
  - schemas/01_document_structure.yml
  - schemas/02_paragraph.yml
  # ... 03-10 ...
  - schemas/11_drawing.yml
  # 12_math.yml is MISSING here
  - schemas/13_charts.yml
```

This means math elements (OMML namespace `m:`) are not loaded through the
schema pipeline. Math element classes exist in `lib/uniword/math/` (69 files)
because they were generated separately, but they're not part of the unified
schema-driven generation workflow.

Additionally, there's a separate `config/ooxml/schemas/math.yml` (standalone)
that may duplicate or conflict with `12_math.yml`.

## Fix

1. Verify `12_math.yml` has correct structure (matches the format of other
   numbered schema files)
2. Check for conflicts with standalone `math.yml`
3. Add `schemas/12_math.yml` to the `schema_files:` array between 11 and 13:

```yaml
schema_files:
  # ... existing entries ...
  - schemas/11_drawing.yml
  - schemas/12_math.yml              # <-- ADD THIS
  - schemas/13_charts.yml
```

4. Update the metadata section (total_elements count, add phase info)
5. If `math.yml` (standalone) is redundant, add a note about it

## Verification

```bash
# Regenerate classes and verify math elements are included
bundle exec rake generate_models  # or whatever the generation task is

# Verify math classes load correctly
bundle exec rspec spec/uniword/math/

# Full test suite
bundle exec rspec
```
