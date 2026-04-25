# Bug 05: Parsed objects retain stale `element_order`, dropping elements during `to_xml`

## Severity: Critical
Silently dropped the `/docProps/app.xml` override from `[Content_Types].xml` during serialization.

## Status: FIXED

Two changes required:

### 1. lutaml-model fix (commit `b5e3e9a` on `perf/deserialization-hot-path-optimizations` branch)
- `ordered?`/`mixed?` now delegate to class mapping instead of reading stale `@ordered`/`@mixed` instance variables
- `model_transform.rb` no longer sets `@ordered`/`@mixed` on `Serialize` instances during parsing
- **Must be merged to main and released before uniword can pick it up**

### 2. uniword fix: remove `mixed_content` from `ContentTypes::Types`
- `mixed_content` implies `ordered` in lutaml-model (`lib/lutaml/xml/mapping.rb:191`: `@ordered = ordered || mixed`)
- Even with the lutaml-model fix, `mixed_content` causes ordered serialization
- `ContentTypes::Types` doesn't need `mixed_content` — `[Content_Types].xml` has no text content between elements
- **File**: `lib/uniword/content_types/types.rb` — remove `mixed_content` from line 18

## Root cause

`lutaml-model`'s `ordered?` check read instance variables (`@ordered`, `@mixed`) that were set during XML parsing and never updated. When collections were replaced wholesale by the reconciler, the stale `element_order` array caused `to_xml` to drop new elements.

Additionally, `ContentTypes::Types` had `mixed_content` which implicitly enables ordered serialization — so even after removing the explicit `ordered` directive, the class was still treated as ordered.

## Verification

After both fixes applied:
```
[Content_Types].xml: 8 <Override> elements including /docProps/app.xml ✓
word/_rels/document.xml.rels: theme/theme1.xml relationship present ✓
Full test suite: 3707 examples, 0 failures ✓
```
