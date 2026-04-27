# lutaml-model Performance Optimizations

## Context

Deserializing large OOXML documents (ISO 690: 4.8MB, 130K nodes) takes ~20s.
The bottleneck is in lutaml-model deserialization, not ZIP or XML parsing.
11 optimizations have been applied, reducing from ~52s to ~20s. Target: ~10s.

All changes are in `/Users/mulgogi/src/lutaml/lutaml-model/`.

## Implementation Sequence

Optimizations are ordered by estimated real-world impact and dependency.

### Phase A: High Impact (~8s potential savings)

#### A1. Reduce predicate overhead
- **File**: `lib/lutaml/xml/model_transform.rb` (value_for_rule, data_to_model)
- **Problem**: 103.7M predicate calls (is_a?, nil?, !) per 148K elements (697 per element)
- **Solution**: Pre-compute `xml_serializable?` class method; reduce is_a? checks in hot loops
- **Estimate**: ~2s real
- **Status**: TODO

#### A2. Eliminate Transformer instantiation
- **File**: `lib/lutaml/model/services/transformer.rb:5-7`
- **Problem**: `Transformer.call` creates `new` instance every call (2.75M calls, 9.6s in Class#new)
- **Solution**: Make `call` a module method; inline ImportTransformer logic
- **Note**: The summary file lists this as "#13 inline ImportTransformer" done, but the actual `Transformer.call` still creates instances. The fast-path skip was done (TODO 12), but instantiation was not eliminated.
- **Estimate**: ~2s real
- **Status**: TODO

#### A3. Inline deserialize for simple rules
- **File**: `lib/lutaml/xml/model_transform.rb:272`
- **Problem**: `MappingRule#deserialize` chains `handle_custom_method || handle_delegate || handle_transform_method` -- 3 method dispatches per rule. 95%+ rules only need the last.
- **Solution**: Check once if full deserialize path is needed; for simple rules, directly `public_send(:"#{rule_to}=", value)`. Cache `has_custom_method_for_deserialization?` at init.
- **Note**: The summary file lists this as "#14" done, but `apply_xml_mapping:272` still calls `rule.deserialize` for every rule.
- **Estimate**: ~3s real
- **Status**: TODO

#### A4. Reduce mappings_for call count
- **File**: `lib/lutaml/xml/model_transform.rb` (lines 194, 215, 303, 452, 523, 624, 786)
- **Problem**: `mappings_for(:xml)` called 2.73M times, each going through TransformationRegistry
- **Solution**: Cache `mappings_for(:xml)` once in `apply_xml_mapping`, pass as parameter to sub-methods
- **Estimate**: ~1.5s real
- **Status**: TODO

### Phase B: Medium Impact (~4s potential savings)

#### B1. Cache Attribute#default per register
- **File**: `lib/lutaml/model/attribute.rb:302-311`
- **Problem**: `Attribute#default` called 1.07M times, recomputing `cast_value(default_value(register), register)` each time. Result is deterministic per (attr, register).
- **Solution**: Cache in `@default_cache[register_key]`. Only cache when `instance_object` is nil (proc defaults depend on instance state).
- **Estimate**: ~1.5s real
- **Status**: TODO

#### B2. Pre-match children to rules (skip 91% of VFR calls)
- **File**: `lib/lutaml/xml/model_transform.rb` (apply_xml_mapping, value_for_rule)
- **Problem**: 1,393,987 rule evaluations; 91.4% have NO matching child element
- **Solution**: Build Set of child namespaced names before rules loop; check rule names against Set before calling value_for_rule
- **Note**: Must handle `multiple_mappings?` (Array rule names)
- **Estimate**: ~2s real
- **Status**: TODO

#### B3. Cache mappings across recursive calls
- **File**: `lib/lutaml/xml/model_transform.rb` (apply_xml_mapping, data_to_model)
- **Problem**: `TransformationRegistry#get_or_build_mapping` called 148K times with Array key comparisons (353 samples in Array#eql?)
- **Solution**: Pass resolved mappings through recursive call chain via `options[:mappings]`
- **Estimate**: ~0.6s real
- **Status**: TODO

### Phase C: GC Reduction (~3s potential savings)

#### C1. Reduce GC pressure from Transform allocations
- **File**: `lib/lutaml/model/transform.rb` (Transform.new)
- **Problem**: 148,955 Transform.new allocations (22.9% of execution is GC). `@attributes` is identical for every element of same class.
- **Solution**: Reuse single Transform per model class, or pass attributes as parameter
- **Estimate**: ~3s real (from GC reduction)
- **Status**: TODO

### Partially Done (keep improving)

#### P1. Cache type per register on Attribute (partial)
- **Done**: `@cached_type_default` for nil/default register, `@type_ns_class_cache`, `@type_ns_uri_cache`, `@serializable_type_cache`
- **Remaining**: `unresolved_type` and `type_with_namespace` not cached
- **Status**: PARTIAL

#### P2. Cache Mapping#mappings (partial)
- **Done**: `@cached_mappings[reg_key]` when finalized
- **Remaining**: `polymorphic_mapping` calls `mappings.find(&:polymorphic_mapping?)` with no caching
- **Status**: PARTIAL

#### P3. Cache get_transformers on MappingRule (partial)
- **Done**: `EMPTY_TRANSFORMERS` fast path when both transforms nil
- **Remaining**: Result not cached per attribute for non-empty case
- **Status**: PARTIAL

#### P4. Reduce normalize_xml_value overhead (partial)
- **Done**: Early nil/uninitialized return
- **Remaining**: No check for value already being correct type from Serializable child
- **Status**: PARTIAL

#### P5. Deferred hash allocation in value_set_for (partial)
- **Done**: `@using_default = nil` deferred allocation in `init_deserialization_state`
- **Remaining**: Still a method dispatch + hash write, not inlined
- **Status**: PARTIAL

#### P6. Reduce hash allocations in VFR (partial)
- **Done**: Skip `merge({})` when child has no namespace
- **Remaining**: `options.except(:mappings)` still unconditional
- **Status**: PARTIAL

## Completed Optimizations (for reference)

| # | Optimization | Real Impact |
|---|-------------|-------------|
| 01 | Skip `build_input_declaration_plan` for non-root elements | ~1s |
| 03 | Cache type/namespace class/URI on Attribute | ~2s |
| 05 | Fast array key in TransformationRegistry | ~2s |
| 06 | Fast path skip transform when no transforms | ~5s |
| 08 | Cache Namespace#all_uris as frozen array | ~0.5s |
| 09 | `allocate_for_deserialization` using allocate + init | ~7s |
| 10 | Cache castable? at MappingRule init | ~0.5s |
| 11 | Cached extract_register_id | -- |
| 12 | Skip ImportTransformer when no transforms | ~1s |
| 23 | value_map fast path (no hash merge when no overrides) | ~0.3s |

## Key Lessons

- Per-instance caches on ModelTransform don't work -- a new instance is created per element
- Caches must live on long-lived objects (rule, attribute, class) to get hit rates
- `allocate_for_deserialization` was the biggest single win (~7s)
- 860K Array#select calls were 100% unnecessary -- eliminated by index early return
- `Lutaml::Model::Hash` module shadows `::Hash` constant -- always use `::Hash` in Lutaml::Model namespace
- Empty hash `{}` is truthy in Ruby -- check `.empty?` before using as boolean
- Pre-match must handle `multiple_mappings?` (Array rule names)
