# 05 — Package#stripped_parts

**Status:** COMPLETED
**Priority:** Medium (reporting surface)
**Depends on:** 03 (StrippedPart)

## Problem

After loading, callers need to know what was stripped at load time.
Today `Package` has no such surface — strips would be invisible.

## Solution

Add `Package#stripped_parts` as a plain `Array<Docx::StrippedPart>`,
default empty. Populated by `RawPartLoader` in `:strip` mode.

```ruby
class Package < Lutaml::Model::Serializable
  # Parts stripped at load because they were non-compliant (no content
  # type, OS artifact, ...). Populated by PartLoader when
  # Configuration#on_noncompliant_content is :strip (default).
  #
  # @return [Array<Docx::StrippedPart>]
  attr_reader :stripped_parts

  def initialize(...)
    super
    @stripped_parts = []
  end
end
```

Note: this is NOT a lutaml-model `attribute` — stripped parts are
load-time metadata, never serialized to XML.

## Why not on DocumentRoot?

`Package` is the load surface (it owns `from_zip_content`). The
classifier runs at package load time, before `DocumentRoot` is
populated. Putting stripped_parts on DocumentRoot would require a
back-reference from document to package, which is wrong directionally.

`Package` is the right home.

## Access from Ruby API

`DocumentFactory.from_file(path)` returns a `DocumentRoot`, not a
`Package`. The user-facing Ruby API needs access too. Options:

- A) Expose via `DocumentRoot#stripped_parts` that delegates to package.
- b) Return a richer result object from `from_file`.

For minimum surface change, go with (A): `DocumentRoot` carries a
reference to its source package's `stripped_parts`. But that introduces
coupling.

Better: the loader returns the `Package`. Callers who care about strips
use `Package.from_file` directly. The Ruby API stays clean. Document
this in the Ruby API page.

## Spec

`spec/uniword/docx/package_stripped_parts_spec.rb`:

- Empty by default on a new package
- Populated after loading a fixture with junk parts
- Contains `StrippedPart` objects with the right path + reason
