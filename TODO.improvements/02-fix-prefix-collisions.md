# 02: Fix VmlWord "w" prefix collision with WordProcessingML

**Priority:** P0 (bug)
**Effort:** Small (~30 min)
**File:** `lib/uniword/ooxml/namespaces.rb:339`

## Problem

`VmlWord` at line 339 uses `prefix_default "w"`, which is the same prefix as
`WordProcessingML` (line 13). When both namespaces appear in the same XML
document, this produces invalid XML with duplicate namespace prefixes.

```ruby
# Line 13: WordProcessingML uses "w"
class WordProcessingML < Lutaml::Xml::Namespace
  uri "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  prefix_default "w"  # <-- collides with VmlWord
end

# Line 339: VmlWord also uses "w"
class VmlWord < Lutaml::Xml::Namespace
  uri "urn:schemas-microsoft-com:office:word"
  prefix_default "w"  # <-- SAME PREFIX!
end
```

The correct prefix for `VmlWord` is `"o"` (used in MS Office XML for
`urn:schemas-microsoft-com:office:word`). However, verify against actual OOXML
usage in the wild — some documents may use `"w10"`.

## Fix

```ruby
# In lib/uniword/ooxml/namespaces.rb, line 341:
# Change from:
prefix_default "w"
# Change to:
prefix_default "o"
```

Then find all generated classes that use `VmlWord` as their namespace and
verify their XML output uses the correct prefix:

```bash
grep -rn 'VmlWord' lib/uniword/
```

## Verification

```bash
# Build a document with VML elements, serialize to XML, check prefixes
bundle exec rspec spec/integration/
```
