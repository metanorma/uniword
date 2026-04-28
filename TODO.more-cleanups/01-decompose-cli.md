# 01: Decompose cli.rb (1112 lines) into CLI subcommand classes

**Priority:** P0 (blocks CLI expansion — every new CLI command adds to this file)
**Effort:** Medium (~4 hours)
**File:** `lib/uniword/cli.rb`

## Problem

`cli.rb` is the largest source file in the codebase at 1112 lines. It contains 4
Thor classes (StyleSetCLI, ResourcesCLI, ThemeCLI, CLI) plus inline helper
methods. Every new CLI command (#08–#20) will add more code here.

Current structure:

```
cli.rb (1112 lines)
├── class StyleSetCLI < Thor          (lines 11-182)    → 172 lines
├── class ResourcesCLI < Thor         (lines 185-340)   → 156 lines
├── class ThemeCLI < Thor             (lines 342-564)   → 223 lines
└── class CLI < Thor                  (lines 567-1112)  → 546 lines
    ├── convert, info, validate       (~120 lines)
    ├── build                         (~50 lines)
    ├── check                         (~50 lines)
    ├── batch                         (~40 lines)
    ├── metadata                      (~60 lines)
    ├── verify                        (~40 lines)
    ├── print_metadata helper         (~50 lines)
    └── registrations + version       (~20 lines)
```

## Fix

Extract each Thor class into its own file under `lib/uniword/cli/`:

```
lib/uniword/cli/
├── main.rb              # CLI class (convert, info, validate, verify, version)
├── styleset_cli.rb      # StyleSetCLI (list, import, apply)
├── resources_cli.rb     # ResourcesCLI (export)
├── theme_cli.rb         # ThemeCLI (list, import, apply, auto)
├── build_command.rb     # BuildCommand module (build)
├── check_command.rb     # CheckCommand module (check)
├── batch_command.rb     # BatchCommand module (batch)
├── metadata_command.rb  # MetadataCommand module (metadata)
└── helpers.rb           # Shared print/format helpers
```

`cli.rb` becomes a loader that requires all subfiles and registers subcommands:

```ruby
# lib/uniword/cli.rb
require_relative "cli/main"

module Uniword
  # CLI entry point — commands are in Uniword::CLI::Main
  CLI = CLI::Main
end
```

Keep `Uniword::CLI.start(argv)` as the public API. All subcommands register
the same way.

## Verification

```bash
bundle exec rspec spec/uniword/cli/
# Verify all CLI commands still work:
bundle exec uniword version
bundle exec uniword theme list
bundle exec uniword styleset list
bundle exec uniword convert --help
```
