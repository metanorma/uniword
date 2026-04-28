# Plan: Word-Accurate Document Statistics

## Status: VERIFIED against Word 2024

All statistics match Microsoft Word 2024 exactly for the test cases.

## Algorithm (Verified)

Based on testing 6 documents in Microsoft Word 2024:

| Rule | Implementation |
|------|---------------|
| **Words** | Whitespace-separated tokens; each CJK char = 1 word |
| **Characters** | Total chars minus whitespace (NO paragraph marks) |
| **CharactersWithSpaces** | Total chars including spaces (NO paragraph marks) |
| **Paragraphs** | Non-empty paragraphs only |
| **Lines** | Same as non-empty paragraph count |
| **Pages** | max(1, ceil(non_empty_paras / 45)) |

### Key Findings

1. **Paragraph marks are NOT counted** in Characters or CharactersWithSpaces.
   Confirmed by: "Hello World" → C=10 (not 11), CWS=11.

2. **Empty paragraphs are excluded** from Paragraph count.
   Confirmed by: "Hello"+""+"World" → P=2 (not 3).

3. **CJK characters count as individual words**.
   Confirmed by: "Hello 你好 World 世界" → W=6.

4. **The hello-world-repaired.docx statistics were a repair artifact**.
   It showed W=1 for "Hello World" — Word's actual count is W=2.

## Files

- `lib/uniword/docx/document_statistics.rb` — Implementation
- `spec/uniword/docx/document_statistics_spec.rb` — Tests (all verified values)
- `script/generate_verification_docs.rb` — Generates test DOCX files
- `verify_stats/` — Verification documents for manual Word testing

## Open Questions (Low Priority)

1. Does Word include footnote/endnote text in statistics?
2. Does Word include header/footer text in statistics?
3. How does Word count Pages/Lines with actual page layout?
