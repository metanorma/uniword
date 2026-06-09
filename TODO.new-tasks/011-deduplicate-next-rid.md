# 011: Deduplicate rId generation — extract shared `next_rid` helper

## Status: DONE

## Problem

Two identical implementations of "next available rId" exist:

1. `PackageSerialization#next_rid` (package_serialization.rb:151)
2. `ReferentialIntegrity#derive_unique_rid` (referential_integrity.rb:304)

Both scan relationships for the highest `rId(\d+)` pattern and return
`rId#{max+1}`. This is a DRY violation.

## Fix

Move `next_rid` into `Helpers` module (already shared by both
`PackageSerialization` is not mixed into the Reconciler, so the cleanest
approach is a standalone utility:

**Option A**: Add to `Helpers` module and have `PackageSerialization`
call it via the package's reconciler or a shared utility.

**Option B (simpler)**: Extract to `Ooxml::Relationships` as a class method:

```ruby
module Ooxml::Relationships
  class PackageRelationships
    def self.next_available_rid(relationships)
      max = relationships.relationships.filter_map do |r|
        r.id[/\ArId(\d+)\z/, 1]&.to_i
      end.max || 0
      "rId#{max + 1}"
    end
  end
end
```

Then both `PackageSerialization#next_rid` and
`ReferentialIntegrity#derive_unique_rid` delegate to it.

## Files
- `lib/uniword/docx/package_serialization.rb` (line 151)
- `lib/uniword/docx/reconciler/referential_integrity.rb` (line 304)
