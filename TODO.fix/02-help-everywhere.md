# 02 — `--help` / `-h` on any command (root, task, nested subcommand)

## Problem
`uniword convert --help` → `ERROR: "uniword convert" was called with
arguments ["--help"]` — Thor treats `--help` as an unknown positional
for tasks with required arguments, so the most-typed help invocation
fails. Affects every task and nested subcommand (29 top-level commands).

## Fix
`Uniword::Cli::HelpSwitch` module overriding the Thor class method
`start`: when the first `--help`/`-h` appears and everything before it
is option-free task path, rewrite argv to `help <task-path...>` and
dispatch. Extended onto every CLI class in
`CLIHelpers::ClassMethods#included` (single wiring point; new CLI
classes inherit it automatically).

## Status
IMPLEMENTED — lib/uniword/cli/help_switch.rb wired via CLIHelpers;
specs: spec/uniword/cli/help_switch_spec.rb.
