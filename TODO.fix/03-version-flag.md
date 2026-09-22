# 03 — `uniword --version` at root level

## Problem
Only `uniword version` works; `uniword --version` (the near-universal
convention) raises unknown-task.

## Fix
`HelpSwitch.start` rewrites root-level `--version` / `-V` to the
existing `version` task.

## Status
IMPLEMENTED — lib/uniword/cli/help_switch.rb;
spec/uniword/cli/help_switch_spec.rb.
