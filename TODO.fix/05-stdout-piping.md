# 05 — stdout piping: `uniword convert in.docx -`

## Problem
Output always requires a file path; the pandoc/soffice convention of
`-` meaning stdout (enabling `| jq`, redirects, pipes without temp
files) is unsupported.

## Fix
`DocumentWriter#save` treats `"-"` as stdout: ZIP formats via
`write_to_stream($stdout, format:)` (binmode), HTML via the HTML
string. `validate_path` accepts `-`. Works for convert (all output
formats); documented in `convert --help`.

## Status
IMPLEMENTED — lib/uniword/document_writer.rb;
spec: spec/uniword/cli/stdout_spec.rb.
