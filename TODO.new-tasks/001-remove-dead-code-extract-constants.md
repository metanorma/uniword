# 001: Remove dead code and extract repeated constants

## Status: DONE

## Changes
1. Remove unused `clean_part_runs` method from reconciler.rb
2. Extract `FULL_IGNORABLE` constant (`"#{EXTENSION_PREFIXES} wp14"`) used 4 times

## Files
- `lib/uniword/docx/reconciler.rb`

## Anti-patterns fixed
- Dead code elimination
