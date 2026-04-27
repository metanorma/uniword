# Uniword Cleanup & CLI Vision Tasks

## Priority Legend
- **P0** = Must-do, blocks other work or fixes bugs
- **P1** = High-value, do next sprint
- **P2** = Medium-value, plan into upcoming work
- **P3** = Vision/backlog, nice-to-have

## Code Cleanups (Architectural)

| # | Priority | Title | Est. |
|---|----------|-------|------|
| 01 | P0 | Decompose cli.rb (1112 lines) into CLI subcommand classes | M |
| 02 | P1 | Decompose run_properties.rb (677 lines) into property submodules | M |
| 03 | P1 | Add smoke tests for 24 untested source directories (558 files) | L |
| 04 | P2 | Decompose HtmlToOoxmlConverter (535 lines) | M |
| 05 | P0 | Fix remaining bare rescue StandardError (math_converter, filter_helper) | S |
| 06 | P2 | Audit metadata subsystem for overlap (6 files, 2094 lines) | M |
| 07 | P2 | Audit properties/ layer (51 files, 1837 lines) vs Builder API | M |

## CLI Vision: Word Alternative for ISO Standards Editors

These tasks make uniword a credible CLI alternative to Microsoft Word for
ISO standards editors, technical writers, and review workflows.

| # | Priority | Title | Est. |
|---|----------|-------|------|
| 08 | P1 | CLI `review` — comments, tracked changes, accept/reject, interactive review | L |
| 09 | P1 | CLI `diff` — structural comparison of two DOCX files | M |
| 10 | P1 | CLI `generate` — style-driven document generation from structured text | L |
| 11 | P2 | CLI `spellcheck` — spell checking (Hunspell) and grammar checking | M |
| 13 | P2 | CLI `images` — extract/insert/list images in documents | S |
| 14 | P2 | CLI `template` — create/apply/list document templates | M |
| 16 | P3 | CLI `watermark` — add/remove text and image watermarks | S |
| 17 | P2 | CLI `toc` — generate/update table of contents | M |
| 18 | P2 | CLI `headers` / `footers` — manage header/footer content | S |
| 19 | P3 | CLI `protect` — set document editing restrictions with password | M |

## Target Personas

| Persona | Key Commands | Use Case |
|---------|-------------|----------|
| ISO Standards Editor | generate, review, spellcheck, toc, diff | Produce ISO publications from structured content, review tracked changes |
| Technical Writer | template, generate, toc, headers, spellcheck | Generate styled documents from templates and structured text |
| Legal Professional | diff, review, spellcheck | Compare contract versions, redline, accept/reject edits |
| QA Engineer | validate, verify, check, diff, spellcheck | Verify DOCX output from pipelines, spell-check before publication |
| Automation Engineer | generate, batch, spellcheck --json | CI/CD integration for DOCX workflows |

## Key Workflow: ISO Document Generation

The primary workflow uniword targets:

1. **Extract styles** from an existing ISO document (461 named styles):
   `uniword styleset extract "ISO 6709.docx" --name iso-6709`

2. **Author content** in structured text (YAML, Markdown, or AsciiDoc)

3. **Generate DOCX** with ISO styles applied:
   `uniword generate document.yml output.docx --style-source "ISO 6709.docx"`

4. **Spell check** before submission:
   `uniword spellcheck output.docx --dictionary iso_terms.txt`

5. **Review changes** during editorial review:
   `uniword review interactive output.docx reviewed.docx`
