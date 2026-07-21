# 02 — ContentTypes::Types#content_type_for lookup

**Status:** COMPLETED
**Priority:** Medium (DRY refactor; required by JunkClassifier)
**Depends on:** nothing

## Problem

Content type resolution for a part path is duplicated in at least two
places:

- `Docx::RawPartLoader#override_type` / `#default_type` —
  `lib/uniword/docx/part_loader/raw_part_loader.rb:119-133`
- `Docx::PackageSerialization#inject_raw_part_content_types` —
  `lib/uniword/docx/package_serialization.rb:411-430`

Both walk `content_types.defaults` and `content_types.overrides` looking
for a match by extension or part name. Same logic, two places, two tests.

## Solution

Add `ContentTypes::Types#content_type_for(path)` returning the Override
content type for `path` first, then the Default content type for its
extension, then nil.

```ruby
class Types < Lutaml::Model::Serializable
  # @param path [String] package-relative path (e.g. "word/document.xml")
  # @return [String, nil] content type declared by Override or Default
  def content_type_for(path)
    override_content_type(path) || default_content_type(path)
  end

  private

  def override_content_type(path)
    part_name = "/#{path}"
    overrides.find { |o| o.part_name == part_name }&.content_type
  end

  def default_content_type(path)
    ext = File.extname(path)[1..]
    return nil unless ext

    defaults.find { |d| d.extension == ext }&.content_type
  end
end
```

## Callsite updates

- `RawPartLoader#content_type_for(package, path)` delegates to
  `package.content_types.content_type_for(path)`. The wrapper still
  handles the nil-content_types case.
- `PackageSerialization#inject_raw_part_content_types` uses the same
  method for the "needs an Override?" decision.

## Spec

`spec/uniword/content_types/types_spec.rb` (or extend existing):

- Returns Override content type when Override matches
- Returns Default content type when no Override but Default extension matches
- Returns nil when neither matches
- Returns nil for paths with no extension
