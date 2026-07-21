# 01 — Noncompliant content policy (design)

**Status:** COMPLETED
**Priority:** High (correctness regression in 1.4.0)
**Branch:** `fix/raw-part-content-type-fallback`
**Supersedes:** `d9d766b5` (octet-stream fallback — reverted)

## Problem

1.4.0 shipped two features that collide at their intersection:

- **Raw-parts preservation** (`Docx::RawPartLoader`): every ZIP entry no
  registry definition claims becomes a `Docx::RawPart` on
  `package.raw_parts`.
- **Write-time integrity gate** (`Docx::PackageIntegrityChecker`):
  OPC-005 fires for any entry whose extension has no `<Default>` and whose
  path has no `<Override>`.

Real-world DOCX files (e.g. Word's own Simple template) carry
`[trash]/*.dat` entries — junk with no content type declaration. They flow
through the loader as `RawPart(content_type: nil)` and trip OPC-005 on save.
Save raises `Uniword::ValidationError`; user cannot write the file back out.

1.3.x silently tolerated this (no integrity gate). 1.4.0 surfaced it.

## Wrong fix (reverted in this change set)

`d9d766b5` injected `<Override ContentType="application/octet-stream">` for
any raw part lacking a content type. That makes saves succeed, but it does
NOT match Word — Word *strips* such parts, doesn't redeclare them. It also
produces larger-than-Word output and silently hides genuinely missing
declarations.

## Correct fix (this change set)

### Classification rule (Word-identical)

At load, every unclaimed ZIP entry falls into exactly one of:

| Class | Definition | Treatment |
|---|---|---|
| **Modelled** | Claimed by a registry loader | Loaded into document model |
| **Legitimate unmodelled** | No loader, BUT has content type (Default or Override) | Preserved as `RawPart` (1.4.0 promise — VBA, glossary, customXml, docProps/meta.xml) |
| **Junk** | No loader AND no content type declaration AND no incoming relationship, OR matches a known OS/tooling pattern | Stripped at load |

Known OS/tooling artifacts (`__MACOSX/`, `.DS_Store`, `Thumbs.db`, `._*`,
`~$*`) are stripped unconditionally even if a Default happens to match.

### Two-mode policy

`Configuration#on_noncompliant_content` controls behavior when junk is
detected at load:

- **`:strip` (default, Word-identical)** — Strip silently. Populate
  `package.stripped_parts`. Log each strip when `log_save_fixes` is true.
- **`:raise` (strict)** — Don't strip. Carry as `RawPart(content_type: nil)`.
  The existing `PackageIntegrityChecker` raises `Uniword::ValidationError`
  with structured OPC-005 issues at save.

Two modes only — caller either gets auto-strip with reporting, or gets
errors raised. No third "report-only" mode muddying the API.

### Verify asymmetry (intentional)

`OpcValidator` opens the ZIP directly via `Zip::File.open`. It does NOT go
through `Package.from_zip_content`. The load-time strip does NOT silence
`uniword verify` on the source. Verify reports source state; save applies
cleanup. This is correct behavior and is documented as such.

## Implementation breakdown

| Item | File |
|---|---|
| Content type lookup method | `lib/uniword/content_types/types.rb` |
| StrippedPart value object | `lib/uniword/docx/stripped_part.rb` |
| JunkClassifier | `lib/uniword/docx/junk_classifier.rb` |
| Package attribute | `lib/uniword/docx/package.rb` |
| Configuration option | `lib/uniword/configuration.rb` |
| Loader filter | `lib/uniword/docx/part_loader/raw_part_loader.rb` |
| Octet-stream revert | `lib/uniword/docx/package_serialization.rb` |
| Autoloads | `lib/uniword/docx.rb` |

## Why this design

- **MECE**: classification lives in one class (`JunkClassifier`); strip
  decision lives in one place (`RawPartLoader`); policy lives in one
  place (`Configuration`); reporting state lives in one place
  (`Package#stripped_parts`). No overlap.
- **OCP**: classifier's pattern list is a constant array — adding a new
  pattern is a data change, not a behavior change. The classification
  method dispatches through `JunkClassifier::Rule` objects; adding a new
  rule type means adding a new `Rule` subclass, not modifying the
  classifier.
- **DRY**: `ContentTypes::Types#content_type_for(path)` becomes the
  single content-type lookup; `RawPartLoader` and `package_serialization`
  both call it.
- **Performance**: classifier precomputes `Set` of default extensions and
  override part names for O(1) lookup. Negligible for typical docx
  (<100 parts), meaningful for adversarial inputs.
- **Model-driven**: classification is based on the loaded
  `ContentTypes::Types` model, not on string matching against raw XML.
