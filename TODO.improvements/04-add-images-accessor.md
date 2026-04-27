# 04: Add images accessor to DocumentRoot

**Priority:** P0 (bug — code references nonexistent method)
**Effort:** Small (~1 hour)
**Files:**
- `lib/uniword/wordprocessingml/document_root.rb` (add method)
- `lib/uniword/format_converter.rb:285` (caller)
- `lib/uniword/metadata/metadata_extractor.rb:208` (caller)

## Problem

Two callers use `document.images` via `respond_to?(:images)` guards, but
`DocumentRoot` has no `images` method. Both callers silently skip image
counting for DOCX documents. Only `Mhtml::Document` (line 141) has `def images`.

```ruby
# format_converter.rb:285
images: document.respond_to?(:images) ? document.images.count : 0
# Always returns 0 for DOCX documents

# metadata_extractor.rb:208
metadata[:image_count] = document.images.size if document.respond_to?(:images)
# Never executes for DOCX documents
```

DOCX images are stored in the package as relationship targets. The data is
available via `Docx::Package` (which reads `word/_rels/document.xml.rels` for
image relationships), but it's not exposed on `DocumentRoot`.

## Fix

Add an `images` method to `DocumentRoot` that collects image references from
embedded drawings:

```ruby
# In lib/uniword/wordprocessingml/document_root.rb
def images
  @images_cache ||= begin
    images = []
    body&.paragraphs&.each do |para|
      # Walk paragraphs for drawing/image references
      # Collect from run.drawing elements
    end
    images
  end
end
```

Alternatively, store the image parts from `Docx::Package` on the DocumentRoot
during `from_file` loading (in `DocumentFactory`).

## Verification

```bash
# After fix, these should return actual image counts for DOCX documents
bundle exec rspec spec/uniword/metadata/
bundle exec rspec spec/integration/
```
