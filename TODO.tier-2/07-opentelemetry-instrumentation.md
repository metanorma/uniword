# 07 — OpenTelemetry instrumentation

**Status:** PLANNED
**Priority:** Medium for enterprise deployment
**Depends on:** nothing

## Why

Enterprise users need observability. Traces for `from_file`, `save`,
`verify`, `repair` make uniword deployable in observability-conscious
environments.

## Scope

- Optional dependency: `opentelemetry-sdk`
- Spans for major operations: load, save, verify, repair,
  reconcile, find-replace
- Trace context propagation through sub-operations
- Metrics: documents processed, latency histograms, error rates
- Logs: structured JSON when configured

## Configuration

```ruby
Uniword.configure do |c|
  c.otel_enabled = true
  c.otel_service_name = "uniword-prod"
end
```

Or via env: `UNIWORD_OTEL_ENABLED=1`.

## Out of scope

- Custom dashboards (user responsibility)
- APM integration code (use otel collector)
