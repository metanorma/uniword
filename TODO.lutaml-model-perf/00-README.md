# lutaml-model Performance Investigation

## Context

Uniword uses lutaml-model to deserialize large OOXML documents. A 4.8MB ISO 690
document (130K nodes) takes ~20s to deserialize. ZIP extraction takes 0.02s,
Nokogiri XML parsing takes 0.05s -- the bottleneck is entirely in
lutaml-model's deserialization pipeline.

## How to Run

All benchmarks are standalone Ruby scripts. They depend on lutaml-model being
available (either via gem install or Bundler with a local path).

```bash
cd lutaml-model                    # or wherever lutaml-model is
bundle exec ruby /path/to/TODO.lutaml-model-perf/01-*.rb
```

Each script:
1. Defines a minimal model to exercise the hot path
2. Generates test XML data
3. Benchmarks the current behavior
4. Points to the exact file:line causing overhead
5. Suggests the implementation change

## Overview of Hotspots

| # | File | Problem | Est. Impact |
|---|------|---------|-------------|
| 01 | `mapping_rule.rb:260-263` | `deserialize` chains 3 methods for 95% of rules | ~3s |
| 02 | `transformer.rb:5-7` | `Transformer.call` creates instance per invocation | ~2s |
| 03 | `model_transform.rb:194,215,303` | `mappings_for` called multiple times per element | ~1.5s |
| 04 | `model_transform.rb:413-681` | 103M predicate calls (is_a?, nil?, !) per 148K elements | ~2s |
| 05 | `attribute.rb:309-311` | `Attribute#default` recomputes deterministic value 1M times | ~1.5s |
| 06 | `model_transform.rb:226-278` | 91% of rules have no matching child (1.27M wasted VFR calls) | ~2s |
| 07 | `transform.rb:7` | 148K `Transform.new` allocations cause 23% GC overhead | ~3s |

Total estimated savings: ~15s (from ~20s to ~5s)
