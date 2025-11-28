# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Paragraph - block-level text element
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:p>
      class Paragraph < Lutaml::Model::Serializable
          attribute :properties, ParagraphProperties
          attribute :runs, Run, collection: true, default: -> { [] }
          attribute :hyperlinks, Hyperlink, collection: true, default: -> { [] }
          attribute :bookmark_starts, BookmarkStart, collection: true, default: -> { [] }
          attribute :bookmark_ends, BookmarkEnd, collection: true, default: -> { [] }
          attribute :field_chars, FieldChar, collection: true, default: -> { [] }
          attribute :instr_text, InstrText, collection: true, default: -> { [] }
          attribute :comment_range_starts, CommentRangeStart, collection: true, default: -> { [] }
          attribute :comment_range_ends, CommentRangeEnd, collection: true, default: -> { [] }
          attribute :comment_references, CommentReference, collection: true, default: -> { [] }

          xml do
            root 'p'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'pPr', to: :properties, render_nil: false
            map_element 'r', to: :runs, render_nil: false
            map_element 'hyperlink', to: :hyperlinks, render_nil: false
            map_element 'bookmarkStart', to: :bookmark_starts, render_nil: false
            map_element 'bookmarkEnd', to: :bookmark_ends, render_nil: false
            map_element 'fldChar', to: :field_chars, render_nil: false
            map_element 'instrText', to: :instr_text, render_nil: false
            map_element 'commentRangeStart', to: :comment_range_starts, render_nil: false
            map_element 'commentRangeEnd', to: :comment_range_ends, render_nil: false
            map_element 'commentReference', to: :comment_references, render_nil: false
          end
      end
    end
  end
end
