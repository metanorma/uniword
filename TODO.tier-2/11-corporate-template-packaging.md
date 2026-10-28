# 11 — Corporate template packaging

**Status:** PLANNED
**Priority:** Medium for enterprise distribution
**Depends on:** plugin system (Tier 2/03), lint rules (Tier 2/09)

## Why

Profile + StyleSet + Theme bundles + lint rules = a "house style"
package installable from a private gem source. Companies can ship
their corporate template as a single gem.

## Scope

- `uniword-corporate-acme` gem that bundles:
  - 2-3 corporate themes
  - 1-2 corporate StyleSets
  - Required corporate profile(s)
  - Corporate lint ruleset
  - Custom corporate templates
- Install: `gem install uniword-corporate-acme`
- Activate: `Uniword.configure { |c| c.corporate = :acme }`
- Or auto-discover via gem metadata

## Architecture

```
Uniword::Corporate
  ├── Package           # gem-aware bundle loader
  ├── ThemeSet          # corporate themes
  ├── StyleSet          # corporate stylesets
  ├── Profile           # corporate profile
  └── LintRuleset       # corporate rules
```

## Out of scope

- Gem hosting (use rubygems.org or private Gemfury)
- Versioned migrations between corporate gem versions
