# 04 — Docx::JunkClassifier

**Status:** COMPLETED
**Priority:** High (core of the strip-at-load fix)
**Depends on:** 02 (`Types#content_type_for`)

## Problem

Junk classification is a single concern with multiple decision criteria.
Without a dedicated class, the logic would leak into `RawPartLoader`,
making it harder to test, harder to extend with new patterns, and
impossible to share with future callers (e.g. a `uniword info` strip
report).

## Solution

`Docx::JunkClassifier` answers one question for one path: is this junk,
and if so, why?

```ruby
module Uniword::Docx
  class JunkClassifier
    OS_ARTIFACT_PATTERNS = [
      /\A__MACOSX\//,         # macOS zip metadata
      /\A\.DS_Store\z/,       # macOS Finder
      /Thumbs\.db\z/,         # Windows Explorer
      /\A\._/,                # macOS AppleDouble
      /\A~\$/,                # Office lock files
    ].freeze

    def initialize(content_types:, relationships_by_path: {})
      @content_types = content_types
      @relationships_by_path = relationships_by_path
    end

    # @param path [String] package-relative path
    # @return [String, nil] reason if junk; nil if legitimate
    def reason(path)
      os_artifact_reason(path) || undeclared_part_reason(path)
    end

    private

    def os_artifact_reason(path)
      return nil unless OS_ARTIFACT_PATTERNS.any? { |p| p.match?(path) }

      "OS or tooling artifact"
    end

    def undeclared_part_reason(path)
      return nil if @content_types&.content_type_for(path)
      return nil if @relationships_by_path.key?(path)

      "No content type declaration and no referencing relationship"
    end
  end
end
```

## Classification rules (in priority order)

1. **OS/tooling artifact** — path matches a known pattern
   (`__MACOSX/`, `.DS_Store`, `Thumbs.db`, `._*`, `~$*`). These are
   never legitimate document content.

2. **Undeclared part** — no content type declaration (neither Override
   nor Default extension match) AND no incoming relationship. This is
   the OPC rule: every part must have a content type.

Either condition classifies the part as junk. Both can apply; the first
match wins.

## Why a class (not a module function)

- **State**: classification depends on the loaded `ContentTypes::Types`
  and the set of resolved relationship targets. A class holds that
  state cleanly.
- **Testing**: a class is easy to instantiate with synthetic inputs.
- **OCP**: the `Rule` array pattern means future rules (e.g. "parts
  larger than X", "parts with extension matching a denylist") can be
  added without modifying the classifier's dispatch.

## Why pattern constants, not a registry

A constant array of regexps is data. Adding a new pattern = appending
one line to a constant. Simple, obvious, no ceremony. If we ever need
runtime extension (plugins), we can wrap it in a registry then.

## Construction

The classifier needs:
- The loaded `ContentTypes::Types` model (for content type lookup)
- The set of paths targeted by some relationship (for the "no incoming
  rel" check)

`RawPartLoader` constructs the classifier with the package's content
types and the relationship target set it already computes for
`referencing_relationship`.

## Autoload

```ruby
# lib/uniword/docx.rb
module Docx
  autoload :JunkClassifier, "#{__dir__}/docx/junk_classifier"
end
```

## Spec

`spec/uniword/docx/junk_classifier_spec.rb`:

- Returns nil for a path with an Override
- Returns nil for a path whose extension has a Default
- Returns nil for a path with no content type but targeted by a rel
- Returns reason for a path with no content type and no rel
- Returns reason for `[trash]/anything.dat` (no content type)
- Returns reason for `__MACOSX/foo` even if a Default matches
- Returns reason for `.DS_Store`, `Thumbs.db`, `._foo`, `~$lock`
