# 03 — Plugin system

**Status:** COMPLETED
**Priority:** Medium (extensibility)
**Depends on:** nothing

## Why

Let users extend uniword without forking. Register custom
validators, transformers, builders, CLI commands.

## Scope

- `Uniword::Plugin.register(:validator, MyCustomRule)`
- `Uniword::Plugin.register(:transformer, MyTransformer)`
- `Uniword::Plugin.register(:cli_command, MyThorCommand)`
- Plugin discovery via `Gem.find_files("uniword/plugin/*.rb")`
- Configuration via `Uniword.configuration.plugins = [...]`

## Use cases

- Corporate house-style validators
- Industry-specific transformers (legal, medical)
- Domain-specific builders (e.g., contract clause library)
- Integration with external systems (DMS, CMS)

## Architecture

```
Uniword::Plugin
  ├── Registry            # name => instance
  ├── Loader              # gem-based discovery
  ├── Validator           # base class for custom validators
  ├── Transformer         # base class for transformers
  └── CliCommand          # base class for CLI extensions
```

## Out of scope

- Plugin sandboxing (security)
- Remote plugins (require explicit install)
