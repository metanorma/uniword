# 07 — respect NO_COLOR

## Problem
Thor's shell colors output on TTYs regardless of the POSIX `NO_COLOR`
convention.

## Fix
`Uniword::Cli::NoColor` prepended onto `Thor::Shell::Basic` (only when
`ENV["NO_COLOR"]` is set) forcing `color?` to false. Wired in
exe/uniword so library consumers are unaffected.

## Status
IMPLEMENTED — lib/uniword/cli/no_color.rb; wired in exe/uniword;
spec: spec/uniword/cli/no_color_spec.rb.
