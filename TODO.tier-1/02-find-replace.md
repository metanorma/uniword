# 02 — find-replace (text)

**Status:** COMPLETED
**Priority:** High (closes ~half the perceived Word parity gap)
**Depends on:** nothing

## Why

Word's single most-used power feature. `uniword fonts replace` exists
(content-level font family swap); a general-purpose text find/replace
with regex, scope selection, and dry-run does not. This is the literal
equivalent of ImageMagick's `convert` for documents.

## Scope

Replace one substring (or regex pattern) with another across a
configurable set of document parts.

### Parts covered (scopes)

| Scope | Targets |
|---|---|
| `body` | `word/document.xml` paragraphs/runs |
| `headers` | All `word/header*.xml` |
| `footers` | All `word/footer*.xml` |
| `footnotes` | `word/footnotes.xml` |
| `endnotes` | `word/endnotes.xml` |
| `comments` | `word/comments.xml` |
| `styles` | Style display names in `word/styles.xml` |
| `numbering` | Numbering definition text in `word/numbering.xml` |
| `all` (default) | Union of the above |

Theme font references (`<a:latin>` in `word/theme/theme1.xml`) are
deliberately out of scope — `uniword theme fonts` handles those.

### Match semantics

- Plain string match (default): literal substring match
- Regex match (`--regex`): Ruby `Regexp`, supports capture groups in
  replacement via `\1`, `\2`, etc.
- Case-insensitive (`--ignore-case`): applies `Regexp::IGNORECASE`

### Run-spanning matches

OOXML splits a paragraph's text into runs at formatting boundaries.
A search string may match across run boundaries. v1 supports
single-run matches only — matches that span runs are silently
skipped (Word does the same in default mode). Document this
limitation; Tier 2 will add cross-run support.

## Architecture

### Classes

```
Uniword::FindReplace
  ├── Engine              # orchestrator: walks scopes, applies matchers
  ├── Scope               # abstract; one strategy per scope
  │   ├── BodyScope
  │   ├── HeaderScope
  │   ├── FooterScope
  │   ├── FootnoteScope
  │   ├── EndnoteScope
  │   ├── CommentScope
  │   ├── StylesScope
  │   └── NumberingScope
  ├── Matcher             # abstract
  │   ├── StringMatcher   # literal substring
  │   └── RegexMatcher    # Regexp with capture references
  └── Result              # count, paths touched, matches per scope
```

### Open/closed

- New scope = new subclass of `FindReplace::Scope` + registration.
  Engine unchanged.
- New matcher type (e.g., format-aware, fuzzy) = new subclass of
  `FindReplace::Matcher`. Engine unchanged.

### MECE

- Scope enumeration lives in `Scope` subclasses (where to look).
- Match logic lives in `Matcher` subclasses (what to look for).
- Engine orchestrates (how to apply).
- Reporting lives in `Result` (what happened).

No overlap.

## Ruby API

```ruby
doc = Uniword::DocumentFactory.from_file("input.docx")

# Replace all, plain string
result = doc.find_replace("foo", "bar")
result.count      # => Integer
result.by_scope   # => { body: 5, headers: 1, ... }

# Regex with capture
doc.find_replace(/Chapter (\d+)/, 'Ch. \1', scope: :body)

# Multiple scopes
doc.find_replace("CONFIDENTIAL", "[REDACTED]",
                 scope: [:headers, :footers])

# Dry run (no mutation, just count)
result = doc.find_replace("foo", "bar", dry_run: true)
doc.save("output.docx")  # unchanged
```

## CLI

```
uniword find-replace INPUT OUTPUT PATTERN REPLACEMENT
  [--scope body|headers|footers|footnotes|endnotes|comments|styles|numbering|all]
  [--regex]
  [--ignore-case]
  [--dry-run]
  [--verbose]
```

Examples:
```bash
# Simple
uniword find-replace report.docx out.docx "Acme" "MegaCorp"

# Regex with capture
uniword find-replace report.docx out.docx 'Chapter (\d+)' 'Ch. \1' --regex

# Scope-specific
uniword find-replace report.docx out.docx "DRAFT" "FINAL" \
  --scope headers --scope footers

# Dry run
uniword find-replace report.docx /dev/null 'foo' 'bar' --dry-run --verbose
```

## Edge cases

- Empty pattern: raise `ArgumentError` (no-op find-replace is a bug).
- Empty replacement: delete matches.
- Pattern matches inside an XML attribute (rare but possible for
  style names): skip — only text nodes are replaced.
- Binary parts (images, embeddings): never touched.
- Match at run boundary: silently skipped in v1.

## Verification

- New spec: `spec/uniword/find_replace/engine_spec.rb`
- New spec: `spec/uniword/find_replace/scope_spec.rb` (one per scope)
- New spec: `spec/uniword/cli/find_replace_cli_spec.rb`
- Integration spec: `spec/integration/find_replace_integration_spec.rb`

## Out of scope (Tier 2)

- Cross-run matching
- Format-aware matching (only match bold text, etc.)
- Replacement with formatting (apply bold to replacement)
- File-system glob input
