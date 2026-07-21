# 03 — Docx::StrippedPart value object

**Status:** COMPLETED
**Priority:** Medium (reporting surface; required by RawPartLoader)
**Depends on:** nothing

## Problem

When the loader strips junk parts, callers need a structured record of
what was dropped and why. A bare `Array<String>` of paths loses the
reason. A `Hash` is untyped. A proper value object gives type safety,
factory methods, and a place to hang future metadata.

## Solution

```ruby
module Uniword::Docx
  class StrippedPart
    attr_reader :path, :reason

    def initialize(path:, reason:)
      @path = path
      @reason = reason
    end

    def_delegators :to_h, :each, :each_pair  # optional, for enumerable parity
  end
end
```

Lightweight — no lutaml-model needed (these never serialize to XML).

## Why a class, not a Struct

`Struct` is forbidden by project convention. A real class gives
typed constructors, immutability (readers only), and a stable equality
contract we control.

## Autoload

Defined in `lib/uniword/docx/stripped_part.rb`. Autoload registered in
`lib/uniword/docx.rb`:

```ruby
module Docx
  autoload :StrippedPart, "#{__dir__}/docx/stripped_part"
end
```

## Spec

`spec/uniword/docx/stripped_part_spec.rb`:

- Constructs with path + reason
- Readers return the values
- Equality by path + reason (value object semantics)
