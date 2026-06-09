# 022: Remove dead MAPPING constants (DOCUMENT_TO_PACKAGE_MAPPINGS, PACKAGE_PART_MAPPINGS)

## Status: DONE

## Problem

Two mapping constants were defined for the old `public_send`-based part-copy
iteration pattern. After TODO 010 eliminated `public_send` with explicit
assignments, these constants became dead code:

1. **`PackageDefaults::DOCUMENT_TO_PACKAGE_MAPPINGS`**
   (`lib/uniword/docx/package_defaults.rb:14`)
   — Defined AND duplicated via `const_set` in `self.included` (line 33-34).
   Never referenced outside its definition.

2. **`DocumentFactory::PACKAGE_PART_MAPPINGS`**
   (`lib/uniword/document_factory.rb:174`)
   — Never referenced outside its definition.

Additionally, `PackageDefaults::self.included` sets the constant on the
including class via `base.const_set`, which is an unnecessary side effect
of module inclusion.

## Fix

1. Delete `DOCUMENT_TO_PACKAGE_MAPPINGS` from `package_defaults.rb`
2. Delete the `self.included` hook (lines 31-35)
3. Delete `PACKAGE_PART_MAPPINGS` from `document_factory.rb`

The explicit assignment lists (`copy_document_parts_to_package`,
`copy_package_parts_to_document`) are the canonical source of truth now.

## Files
- `lib/uniword/docx/package_defaults.rb` (lines 14-35)
- `lib/uniword/document_factory.rb` (lines 174-191)
