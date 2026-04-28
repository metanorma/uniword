# 17: Add CLI `build` command for document creation

**Priority:** P3 (backlog)
**Effort:** Medium (~6 hours)
**Files:**
- `lib/uniword/cli.rb` (add command)
- `lib/uniword/builder/` (existing Builder API — 20 files)

## Problem

The Builder API (`lib/uniword/builder/`) provides a comprehensive Ruby DSL for
creating documents — paragraphs, tables, lists, formatting, images, headers,
footers, etc. But there's no CLI surface for any of it.

This is lower priority than other CLI gaps because programmatic document
creation is inherently a code task, not a CLI task. But a CLI `build` command
could serve simple use cases (generate a document from a template/data file).

## Proposed CLI

```bash
# Build from a YAML/JSON recipe
uniword build --recipe recipe.yml OUTPUT.docx

# Build from template + data
uniword build --template letter.docx --data data.json OUTPUT.docx

# Simple one-liner document
uniword build --title "Report" --text "Hello world" OUTPUT.docx
```

## Implementation approach

This is speculative. The simplest useful version:

```yaml
# recipe.yml
title: "Quarterly Report"
author: "Finance Team"
paragraphs:
  - text: "Q4 2024 Financial Summary"
    style: "Heading1"
  - text: "Revenue increased by 15% year-over-year."
    bold: true
  - table:
      headers: ["Metric", "Q3", "Q4", "Change"]
      rows:
        - ["Revenue", "$1.2M", "$1.4M", "+15%"]
        - ["Profit", "$300K", "$350K", "+17%"]
```

Then a `RecipeParser` translates YAML into Builder API calls.

This is a significant feature, not just a CLI wrapper. Only pursue if there's
user demand.

## Verification

```bash
bundle exec rspec spec/uniword/builder/
```
