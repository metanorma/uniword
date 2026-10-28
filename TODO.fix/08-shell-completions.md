# 08 — shell completions (bash / zsh / fish)

## Problem
29 top-level commands plus nested subcommands are undiscoverable while
typing; no completion support ships with the gem.

## Fix
`uniword completions [SHELL]` (bash|zsh|fish, default bash) emits a
self-contained completion script built from live CLI metadata
(`all_commands` of the root class and every registered subcommand
class), so new commands appear in completions automatically.

## Status
IMPLEMENTED — lib/uniword/cli/completions.rb + `completions` task in
lib/uniword/cli/main.rb; spec: spec/uniword/cli/completions_spec.rb.
