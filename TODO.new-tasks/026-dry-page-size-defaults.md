# 026: DRY page size and margin defaults between reconciler and builder

## Status: DONE

## Problem

US Letter page size (width: 12_240, height: 15_840) and default margins
(top/right/bottom/left: 1440, header/footer: 720, gutter: 0) are hardcoded
in two places:

- `Reconciler::Body#reconcile_section_properties` (body.rb:18-26 and 35-48)
- `SectionBuilder#page_size` and `#margins` (section_builder.rb:34-53)

If the defaults need to change, both must be updated. The column default
(space: 720) and docGrid default (line_pitch: 360) are also duplicated.

## Fix

Extract page layout defaults into a shared location:

```ruby
module Uniword
  module Wordprocessingml
    module PageDefaults
      LETTER_WIDTH  = 12_240
      LETTER_HEIGHT = 15_840
      DEFAULT_MARGINS = { top: 1440, right: 1440, bottom: 1440, left: 1440,
                          header: 720, footer: 720, gutter: 0 }.freeze
      DEFAULT_COL_SPACE = 720
      DEFAULT_LINE_PITCH = 360

      def self.default_page_size
        Wordprocessingml::PageSize.new(width: LETTER_WIDTH, height: LETTER_HEIGHT)
      end

      def self.default_page_margins
        Wordprocessingml::PageMargins.new(**DEFAULT_MARGINS)
      end
    end
  end
end
```

## Files
- `lib/uniword/docx/reconciler/body.rb` (lines 18-26, 35-48)
- `lib/uniword/builder/section_builder.rb` (lines 34-53, 106-109)
