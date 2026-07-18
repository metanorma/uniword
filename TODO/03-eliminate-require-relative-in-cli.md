# 15 — Eliminate `require_relative` from `lib/uniword/cli.rb`

**Status: COMPLETED via TODO.validate/12** — `lib/uniword/cli.rb` was
already a namespace stub; all CLI classes autoload from
`lib/uniword.rb:136-149`. All remaining `require_relative` sites in
lib/ (wordprocessingml models, validation namespace) were converted to
autoloads registered in the immediate parent namespace files. Verified:
`exe/uniword help`, `exe/uniword verify`, CLI specs green.

**Priority:** High (forbidden pattern in lib)
**Files:** `lib/uniword/cli.rb`, `lib/uniword/cli/main.rb` (if needed)

## Problem

`lib/uniword/cli.rb` has 10 `require_relative` lines for sub-CLI modules:

```ruby
require_relative "cli/helpers"
require_relative "cli/styleset_cli"
require_relative "cli/resources_cli"
# ... 7 more
```

Project rule: never use `require_relative` for internal library code.
Use Ruby `autoload` instead, defined in the immediate parent
namespace's file.

## Fix

Replace the 10 `require_relative` lines with `autoload` entries inside
the `module CLI` (or wherever the namespace is declared):

```ruby
module CLI
  autoload :Helpers, "uniword/cli/helpers"
  autoload :StylesetCli, "uniword/cli/styleset_cli"
  # ...
end
```

Autoload paths use the load-path-relative form (`"uniword/cli/helpers"`)
not the file-relative form.

## Verification

- `bundle exec ruby -run -e httpd -- -p 0 doc/` style smoke tests
  still load the CLI without errors
- `bundle exec rubocop lib/uniword/cli.rb` reports 0 require_relative
  offenses
- `bundle exec rspec spec/uniword/cli/` passes
