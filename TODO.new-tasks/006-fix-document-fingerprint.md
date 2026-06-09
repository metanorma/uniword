# 006: Fix document_fingerprint to include table cell text

## Status: DONE

## Problem
`document_fingerprint` only iterates `body.paragraphs` but misses paragraphs
inside table cells. Paragraphs in tables also get rsid/paraId derived from
the fingerprint, so the fingerprint should include their text too.

## Solution
Use `walk_body_paragraphs` (which traverses tables) to collect all paragraph
text for the fingerprint.

## Files
- `lib/uniword/docx/reconciler/helpers.rb`
