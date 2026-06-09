# 021: DRY DEFAULT_TABLE_LOOK duplication between builder and reconciler

## Status: DONE

## Problem

`DEFAULT_TABLE_LOOK` is defined identically in two places:

- `lib/uniword/builder/table_builder.rb:18` — `TableBuilder::DEFAULT_TABLE_LOOK`
- `lib/uniword/docx/reconciler/tables.rb:11` — `Tables::DEFAULT_TABLE_LOOK`

Both define the same `Properties::TableLook` with identical values:
```ruby
Properties::TableLook.new(
  val: "04A0", first_row: 1, last_row: 0,
  first_column: 1, last_column: 0,
  no_h_band: 0, no_v_band: 1,
)
```

Additionally, both sites manually copy all 7 properties from the constant
into new `TableLook` instances (lines 82-88 in table_builder.rb, lines 69-86
in tables.rb) instead of using a shared factory or dup.

## Fix

Extract to a shared location (either `Wordprocessingml::TableDefaults` or
`Properties::TableLook::DEFAULT`):

```ruby
# In properties/table_look.rb or a new defaults module
module Uniword
  module Wordprocessingml
    module TableDefaults
      DEFAULT_TABLE_LOOK = Properties::TableLook.new(
        val: "04A0", first_row: 1, last_row: 0,
        first_column: 1, last_column: 0,
        no_h_band: 0, no_v_band: 1,
      ).freeze

      def self.default_table_look
        Properties::TableLook.new(
          val: DEFAULT_TABLE_LOOK.val,
          first_row: DEFAULT_TABLE_LOOK.first_row,
          # ... etc
        )
      end
    end
  end
end
```

Then both `TableBuilder` and `Reconciler::Tables` call
`TableDefaults.default_table_look`.

## Files
- `lib/uniword/builder/table_builder.rb` (lines 18-27, 81-89)
- `lib/uniword/docx/reconciler/tables.rb` (lines 11-19, 68-86)
