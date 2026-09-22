# 01 — Exit codes: task return values leak as process exit status

## Problem
`exe/uniword` ends with `Uniword::CLI.start(ARGV)`, and Thor's `start`
returns the invoked task's return value. `convert` ends with
`doc.save(...)`, whose chain (`DocumentWriter#save` → `Package#to_file` →
`ZipPackager#package`) returns a truthy non-nil value — so a SUCCESSFUL
conversion exits **1**. Any nonzero exit from scripts/CI is therefore
meaningless.

Failures exit 1 correctly (`handle_error` calls `exit 1`; Thor arity /
unknown-command errors exit 1 via `CLIHelpers::ClassMethods#exit_on_failure?`).

## Fix
`exe/uniword`:

    Uniword::CLI.start(ARGV)
    exit 0

Failures raise `SystemExit` inside `start` (never reaching `exit 0`);
success always exits 0 regardless of task return values.

## Status
IMPLEMENTED — exe/uniword; contract spec:
spec/uniword/cli/cli_contract_spec.rb (Open3, real process exits).
