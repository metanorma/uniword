# 11 — `generate`: doubled verb forces `uniword generate generate`

## Problem
The `generate` subcommand group contains exactly one task, also named
`generate`, so the usable invocation is
`uniword generate generate input.md output.docx --style-source tpl.docx`.
Every other single-purpose group dispatches its verb once
(`uniword spellcheck check FILE` reads naturally because the group is
a noun and the task a verb; `generate generate` is a stutter).

## Fix
`GenerateCLI.default_task :generate` — Thor dispatches unmatched
arguments to the default task, so both forms work:

    $ uniword generate input.md output.docx --style-source iso.dotx
    $ uniword generate generate input.md output.docx --style-source iso.dotx

The old doubled form remains valid (backwards compatible); help and
completions are unchanged.

## Status
IMPLEMENTED — lib/uniword/cli/generate_cli.rb (default_task);
specs: spec/uniword/cli_generate_default_task_spec.rb.
