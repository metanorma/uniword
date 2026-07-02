# 07 — DRY IdAllocator seeding between Package and DocumentBuilder

**Priority:** High (architecture / DRY)
**Files:** `lib/uniword/docx/package.rb`,
`lib/uniword/builder/document_builder.rb`

## Problem

`Package#populate_allocator` (package.rb:429–437) and the just-added
`DocumentBuilder.from_template.seed_allocator` class method
(document_builder.rb:132–141) are **character-for-character identical**
(verified by `diff`):

```ruby
allocator = IdAllocator.new
allocator.seed_from_rels(document_rels&.relationships)
allocator.seed_from_rels(package_rels&.relationships)
allocator.seed_from_notes(
  footnotes&.footnote_entries,
  endnotes&.endnote_entries,
)
```

Two copies of the same logic. Future changes to seeding logic
(e.g., seeding from chart rels, or bookmark IDs) require editing both.

## Root cause

`DocumentBuilder.from_template` was added without checking whether
Package already had an equivalent method.

## Fix

Extract to `IdAllocator.populate_from_package(package)`:

```ruby
class IdAllocator
  def self.populate_from_package(package)
    alloc = new
    alloc.seed_from_rels(package.document_rels&.relationships)
    alloc.seed_from_rels(package.package_rels&.relationships)
    alloc.seed_from_notes(
      package.footnotes&.footnote_entries,
      package.endnotes&.endnote_entries,
    )
    alloc
  end
end
```

Then both `Package#populate_allocator` and
`DocumentBuilder.from_template.seed_allocator` delegate to it:

```ruby
# package.rb
def populate_allocator
  @allocator = IdAllocator.populate_from_package(self)
end

# document_builder.rb
def self.seed_allocator(root)
  root.allocator = IdAllocator.populate_from_package(root)
end
```

### Verification

Spec for `IdAllocator.populate_from_package` covering: nil package,
package with only document_rels, package with all sources.
