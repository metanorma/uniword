# 08 — Redact / anonymize

**Status:** PLANNED
**Priority:** High for compliance + legal
**Depends on:** find-replace (Tier 1)

## Why

Strip identifying metadata (rsids, author info, revision metadata,
hidden text) and replace sensitive strings with `[REDACTED]`.
Compliance use case Word cannot serve.

## Scope

- `uniword redact FILE` with patterns:
  - `--pii` auto-detect SSN/email/phone/credit-card patterns
  - `--names LIST` redact specific names
  - `--regex PATTERN` custom regex
  - `--metadata` strip all author/rsid info
- Replacement text customizable: `[REDACTED]`, `___`, custom

## Architecture

Built on find-replace + metadata cleaner. Adds pattern library for
common PII types.

## Out of scope

- OCR of images to find PII in scanned docs
- Steganography detection in embedded objects
