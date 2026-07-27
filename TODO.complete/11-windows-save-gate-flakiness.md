# 11 — Windows save-gate test flakiness

**Status:** COMPLETED
**Priority:** High (CI flakiness)
**Depends on:** nothing

## Problem

`spec/uniword/docx/package_save_gate_spec.rb:65-72` ("does not write
the file when the gate rejects the package") intermittently fails on
Windows CI with:

```
expected: false
     got: true
```

The save chain is correctly ordered — `Package#to_file` calls
`to_zip_content(validate:)` (gate runs here) before `ZipPackager#package`
writes anything. A gate-rejected save never creates `output_path`. So
the file the test sees as existing comes from a prior test, with
cleanup failing on Windows.

Three fragilities compound:

1. **GC lag on file handles.** Test 2 ("produces no referential repair
   fixes") constructs a `Package` locally; the package instance holds
   `raw_xml_parts` / `applied_fixes` references. Ruby's GC on Windows
   is lazier; if collection is delayed past the `after` block, the OS
   file handle stays open, `File.delete` returns `EACCES`, and
   `safe_delete` exhausts its 5 retries (1 s budget) silently.
2. **Temp file not in test cleanup scope.** `ZipPackager#package`
   writes to `"#{output_path}.#{Process.pid}.tmp"` then moves it; its
   own `ensure` does `FileUtils.rm_f(temp_path)` — single attempt, no
   retries. The test's `after` only cleans `output_path`, never the
   temp pattern.
3. **Antivirus / Defender scanning.** Newly-created `.docx` files get
   scanned; during the scan window `File.delete` returns `EACCES`.

## Solution

Three-layer hardening, smallest change first:

### Layer 1: make the test order-independent

The minimum fix. Pre-clean `output_path` and any leaked temp files at
the start of the "invalid output" describe block. Tests stop depending
on the `after` block of the previous test having fully released the
file handle.

### Layer 2: strengthen `safe_delete`

Bump retries from 5 to 10 (≈3 s budget), add `Errno::ENOTEMPTY` to the
rescue list, lengthen per-retry sleep to 0.3 s. Applies to every
callsite; durable fix for the whole suite.

### Layer 3: harden `ZipPackager#package` temp cleanup

Give the temp-file `ensure` the same retry-on-EACCES contract that
`move_temp_to_output` already uses. Stops the temp file leak at the
source.

## Why all three

Layer 1 fixes the test failure. Layer 2 hardens every other test that
cleans up files on Windows. Layer 3 prevents the underlying leak.
Defensive in depth: any one layer alone leaves a residual risk.

## Why the test isn't actually wrong about its assertion

`Package#to_file` (line 249-253) is correct — gate first, packager
second. The test assertion ("file should not exist after gate
rejection") is correct. The flakiness is environmental, not a bug in
the save path.

## Verification

Run the full `package_save_gate_spec.rb` locally — all examples pass
on macOS/Linux. The Windows fix is verified by the next CI run on
`windows-latest`.

## Files touched

- `spec/spec_helper.rb` — strengthen `safe_delete`
- `spec/uniword/docx/package_save_gate_spec.rb` — pre-clean in
  "invalid output" describe
- `lib/uniword/infrastructure/zip_packager.rb` — retry temp cleanup on
  EACCES
