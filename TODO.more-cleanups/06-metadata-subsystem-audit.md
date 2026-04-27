# 06: Audit metadata subsystem for overlap (6 files, 2094 lines)

**Priority:** P2
**Effort:** Medium (~3 hours)
**Files:**
- `lib/uniword/metadata/metadata.rb` (345 lines)
- `lib/uniword/metadata/metadata_index.rb` (455 lines)
- `lib/uniword/metadata/metadata_extractor.rb` (403 lines)
- `lib/uniword/metadata/metadata_manager.rb` (334 lines)
- `lib/uniword/metadata/metadata_updater.rb` (243 lines)
- `lib/uniword/metadata/metadata_validator.rb` (314 lines)

## Problem

The metadata subsystem has 6 classes totaling 2094 lines. Two are suspiciously
large:

- `MetadataIndex` (455 lines) — batch operations and indexing
- `MetadataExtractor` (403 lines) — single-document extraction

These two may overlap with `MetadataManager` (334 lines) and `Metadata` (345
lines). If the Manager wraps the Index and Extractor, and Metadata wraps all of
them, the layering may add indirection without clear boundaries.

## Audit Questions

1. Does `MetadataManager` delegate to `MetadataExtractor` and `MetadataIndex`,
   or does it duplicate their logic?
2. Does `Metadata` (the 345-line class) overlap with `MetadataManager`?
3. Can `MetadataValidator` be merged into the `Validation` subsystem
   (`lib/uniword/validation/`) rather than living in `metadata/`?
4. Does `MetadataIndex` re-implement any querying that Ruby's `Enumerable`
   already provides?

## Fix

After audit:

- Remove any duplicated extraction/indexing logic
- Ensure a clear call chain: `Metadata` → `MetadataManager` → `Extractor/Index`
- Move `MetadataValidator` to `Validation::MetadataValidator` if it shares
  patterns with the existing validation subsystem
- Remove any dead code from classes that exist solely as pass-throughs

## Verification

```bash
bundle exec rspec spec/uniword/metadata/
bundle exec rspec spec/uniword/cli/ --format progress
```
