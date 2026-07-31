# Tier 3 — Strategic bets (6-12 months)

Big swings that expand uniword's reach beyond the Ruby ecosystem or
fundamentally change what the library can do. Each is a major
engineering investment.

## Items

| # | Item | Why it's Tier 3 |
|---|---|---|
| 01 | [PDF export (LibreOffice bridge)](01-pdf-export-libreoffice.md) | Adds heavy runtime dep |
| 02 | [HTTP API + Docker](02-http-api-docker.md) | New deployment surface |
| 03 | [Native PDF writer](03-native-pdf-writer.md) | Multi-month, replaces LibreOffice |
| 04 | [Python bindings](04-python-bindings.md) | Cross-language work |
| 05 | [Node.js bindings](05-nodejs-bindings.md) | Cross-language work |
| 06 | [Public demo site](06-public-demo-site.md) | Hosting infra |
| 07 | [Benchmarks page](07-benchmarks-page.md) | Marketing infra |
| 08 | [Template marketplace](08-template-marketplace.md) | Community infra |
| 09 | [ODF interop](09-odf-separate-library.md) | Separate library, linked here |

## Why these are deferred

Each Tier 3 item changes uniword's surface area significantly — new
runtime dependencies, new deployment targets, new audiences. Better
to land Tier 1 + Tier 2 first so the core is rock-solid before
expanding outward.

The exception is **ODF interop**: explicitly a separate library
(`uniword-odf` or similar) because ODF is a different file format
family (OASIS ODF vs ECMA OOXML), not a wrapper around uniword.
Linked here so it's known as a strategic direction.
