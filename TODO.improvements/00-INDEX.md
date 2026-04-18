# Uniword Improvement Tasks

## Priority Legend
- **P0** = Bug, fix immediately
- **P1** = High-value improvement, do next
- **P2** = Medium-value, plan into upcoming work
- **P3** = Nice-to-have, backlog

## Status Legend
- DONE = Implemented and tested
- REVERTED = Fix was incorrect, no change needed
- DEFERRED = Too risky without dedicated test coverage

## Task Summary

| # | Priority | Title | Status |
|---|----------|-------|--------|
| 01 | P0 | Remove duplicate namespace class definitions | DONE |
| 02 | P0 | Fix VmlWord "w" prefix collision with WordProcessingML | DONE |
| 03 | P0 | Make DocumentRoot.valid? meaningful | DONE |
| 04 | P0 | Add images accessor to DocumentRoot | DONE |
| 05 | P0 | Replace silent exception swallowing with logging | DONE |
| 06 | P1 | Add 12_math.yml to schema_loader pipeline | DONE |
| 07 | P1 | Complete DotxPackage stubs (fontTable, settings, etc.) | DONE |
| 08 | P1 | Add color_scheme and font_scheme to Resource::Importer | DONE |
| 09 | P1 | Deduplicate from_html / html_to_doc | DONE |
| 10 | P2 | Decompose OoxmlToMhtmlConverter (1394 lines) | DONE |
| 11 | P2 | Decompose Docx::Package (1019 lines) | DONE |
| 12 | P2 | Refactor repetitive if-chain in copy_package_parts_to_document | DONE |
| 13 | P1 | Add CLI `html` command for HTML import/export | DONE |
| 14 | P2 | Add CLI `batch` command for multi-document processing | DONE |
| 15 | P2 | Add CLI `check` command for accessibility/quality | DONE |
| 16 | P2 | Add CLI `metadata` command for reading/writing metadata | DONE |
| 17 | P3 | Add CLI `build` command for document creation | DONE |
| 18 | P1 | Add tests for 26 untested source directories (663 files) | DONE — 56 autoload smoke tests |
| 19 | P2 | Fix orphaned shared examples and duplicated helpers | DONE |
| 20 | P1 | Update gemspec Ruby version, gem groups, optional deps | DONE |

## Detailed Task Files

| # | File | Priority | Title | Est. Effort |
|---|------|----------|-------|-------------|
| 01 | [01-fix-duplicate-namespaces.md](01-fix-duplicate-namespaces.md) | P0 | Remove duplicate namespace class definitions | S |
| 02 | [02-fix-prefix-collisions.md](02-fix-prefix-collisions.md) | P0 | Fix VmlWord "w" prefix collision with WordProcessingML | S |
| 03 | [03-fix-valid-always-true.md](03-fix-valid-always-true.md) | P0 | Make DocumentRoot.valid? meaningful | S |
| 04 | [04-add-images-accessor.md](04-add-images-accessor.md) | P0 | Add images accessor to DocumentRoot | S |
| 05 | [05-fix-silent-exceptions.md](05-fix-silent-exceptions.md) | P0 | Replace silent exception swallowing with logging | S |
| 06 | [06-add-math-schema.md](06-add-math-schema.md) | P1 | Add 12_math.yml to schema_loader pipeline | S |
| 07 | [07-complete-dotx-package.md](07-complete-dotx-package.md) | P1 | Complete DotxPackage stubs (fontTable, settings, etc.) | M |
| 08 | [08-complete-resource-importer.md](08-complete-resource-importer.md) | P1 | Add color_scheme and font_scheme to Resource::Importer | S |
| 09 | [09-remove-duplicate-html-api.md](09-remove-duplicate-html-api.md) | P1 | Deduplicate from_html / html_to_doc | S |
| 10 | [10-decompose-ooxml-to-mhtml.md](10-decompose-ooxml-to-mhtml.md) | P2 | Decompose OoxmlToMhtmlConverter (1394 lines) | M |
| 11 | [11-decompose-docx-package.md](11-decompose-docx-package.md) | P2 | Decompose Docx::Package (1019 lines) | M |
| 12 | [12-refactor-copy-parts.md](12-refactor-copy-parts.md) | P2 | Refactor repetitive if-chain in copy_package_parts_to_document | S |
| 13 | [13-add-cli-html-command.md](13-add-cli-html-command.md) | P1 | Add CLI `html` command for HTML import/export | S |
| 14 | [14-add-cli-batch-command.md](14-add-cli-batch-command.md) | P2 | Add CLI `batch` command for multi-document processing | M |
| 15 | [15-add-cli-check-command.md](15-add-cli-check-command.md) | P2 | Add CLI `check` command for accessibility/quality | S |
| 16 | [16-add-cli-metadata-command.md](16-add-cli-metadata-command.md) | P2 | Add CLI `metadata` command for reading/writing metadata | S |
| 17 | [17-add-cli-builder-command.md](17-add-cli-builder-command.md) | P3 | Add CLI `build` command for document creation | M |
| 18 | [18-expand-test-coverage.md](18-expand-test-coverage.md) | P1 | Add tests for 26 untested source directories (663 files) | L |
| 19 | [19-fix-test-infrastructure.md](19-fix-test-infrastructure.md) | P2 | Fix orphaned shared examples and duplicated helpers | S |
| 20 | [20-update-dependencies.md](20-update-dependencies.md) | P1 | Update gemspec Ruby version, gem groups, optional deps | S |
