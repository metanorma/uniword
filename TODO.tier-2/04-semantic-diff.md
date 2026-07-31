# 04 — Semantic diff

**Status:** PLANNED
**Priority:** Medium
**Depends on:** existing diff (text-level)

## Why

Current `uniword diff` is at text/XML level. Element-level semantic
diff ("paragraph reformatted", "row added", "image moved") is closer
to git's structural diffs and far more readable.

## Scope

- Element-level diff: paragraphs, runs, tables, images
- Change classification: added, removed, modified, moved
- For modifications: classify what changed (text, formatting,
  structure)
- Output: structured diff report + git-style unified format

## CLI

```
uniword diff semantic OLD NEW [--format unified|json|html]
```

## Architecture

```
Uniword::Diff::Semantic
  ├── TreeMatcher        # match elements between OLD and NEW
  ├── ChangeClassifier   # added/removed/modified/moved
  ├── FormatDiffer       # text vs format vs structure change
  └── Reporter           # unified diff / JSON / HTML output
```

Uses an LCS or histogram diff at the element level.

## Out of scope

- 3-way merge (that's `combine` in Tier 1)
- Diff visualization GUI
