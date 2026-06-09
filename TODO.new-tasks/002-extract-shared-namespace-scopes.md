# 002: Extract shared namespace_scope constant

## Status: DONE

## Problem
5 model files (footnotes.rb, endnotes.rb, header.rb, footer.rb, numbering.rb)
contain an identical 33-entry `namespace_scope` block (~55 lines each, ~275 lines total).

## Solution
Extract into `Ooxml::Namespaces::DOCUMENT_PART_SCOPES` constant.
Each model references the constant instead of inlining the array.

## Files
- `lib/uniword/ooxml/namespaces.rb` — add constant
- `lib/uniword/wordprocessingml/footnotes.rb` — use constant
- `lib/uniword/wordprocessingml/endnotes.rb` — use constant
- `lib/uniword/wordprocessingml/header.rb` — use constant
- `lib/uniword/wordprocessingml/footer.rb` — use constant
- `lib/uniword/wordprocessingml/numbering.rb` — use constant

## DRY savings: ~220 lines
