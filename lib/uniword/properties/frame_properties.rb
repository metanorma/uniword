# frozen_string_literal: true

require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Frame properties for text boxes and drop caps
    # Represents OOXML framePr element for positioned text frames
    class FrameProperties < Lutaml::Model::Serializable
      xml do
        element 'framePr'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'dropCap', to: :drop_cap
        map_attribute 'lines', to: :lines
        map_attribute 'w', to: :width
        map_attribute 'h', to: :height
        map_attribute 'vspace', to: :vspace
        map_attribute 'hspace', to: :hspace
        map_attribute 'wrap', to: :wrap
        map_attribute 'hAnchor', to: :h_anchor
        map_attribute 'vAnchor', to: :v_anchor
        map_attribute 'x', to: :x
        map_attribute 'y', to: :y
        map_attribute 'hRule', to: :h_rule
        map_attribute 'anchorLock', to: :anchor_lock
      end

      # Drop cap style (none, drop, margin)
      # - none: No drop cap
      # - drop: Drop cap in text margin
      # - margin: Drop cap in page margin
      attribute :drop_cap, :string

      # Number of lines for drop cap (1-10)
      attribute :lines, :integer

      # Frame width in twips
      attribute :width, :integer

      # Frame height in twips
      attribute :height, :integer

      # Vertical space around frame in twips
      attribute :vspace, :integer

      # Horizontal space around frame in twips
      attribute :hspace, :integer

      # Text wrapping (none, around, notBeside, through, tight, none)
      # Common values: none, around, tight
      attribute :wrap, :string

      # Horizontal anchor (margin, page, text)
      # - margin: Relative to page margin
      # - page: Relative to page edge
      # - text: Relative to text column
      attribute :h_anchor, :string

      # Vertical anchor (margin, page, text)
      # - margin: Relative to page margin
      # - page: Relative to page edge
      # - text: Relative to text line
      attribute :v_anchor, :string

      # Horizontal position in twips
      attribute :x, :integer

      # Vertical position in twips
      attribute :y, :integer

      # Height rule (auto, atLeast, exact)
      # - auto: Automatic height
      # - atLeast: Minimum height
      # - exact: Exact height
      attribute :h_rule, :string

      # Anchor lock - prevents frame from moving with text
      attribute :anchor_lock, :boolean, default: -> { false }

      # Convenience method to create a drop cap
      def self.drop_cap(lines = 3, drop_cap = 'drop')
        new(drop_cap: drop_cap, lines: lines)
      end

      # Convenience method to create a margin drop cap
      def self.margin_drop_cap(lines = 3)
        new(drop_cap: 'margin', lines: lines)
      end

      # Convenience method to create a positioned text box
      def self.text_box(x, y, width, height, wrap = 'around', h_anchor = 'margin', v_anchor = 'margin')
        new(
          x: x,
          y: y,
          width: width,
          height: height,
          wrap: wrap,
          h_anchor: h_anchor,
          v_anchor: v_anchor
        )
      end

      # Check if this is a drop cap frame
      def drop_cap?
        !drop_cap.nil? && drop_cap != 'none'
      end

      # Check if this is a positioned text box
      def text_box?
        !x.nil? && !y.nil? && !width.nil? && !height.nil?
      end

      # Get effective width (considering height rule)
      def effective_width
        width
      end

      # Get effective height (considering height rule)
      def effective_height
        height
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        drop_cap == other.drop_cap &&
          lines == other.lines &&
          width == other.width &&
          height == other.height &&
          vspace == other.vspace &&
          hspace == other.hspace &&
          wrap == other.wrap &&
          h_anchor == other.h_anchor &&
          v_anchor == other.v_anchor &&
          x == other.x &&
          y == other.y &&
          h_rule == other.h_rule &&
          anchor_lock == other.anchor_lock
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [drop_cap, lines, width, height, vspace, hspace, wrap,
         h_anchor, v_anchor, x, y, h_rule, anchor_lock].hash
      end
    end

    # Section properties for page layout and formatting
    class SectionProperties < Lutaml::Model::Serializable
      xml do
        element 'sectPr'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'footnotePr', to: :footnote_properties
        map_element 'endnotePr', to: :endnote_properties
        map_element 'type', to: :section_type
        map_element 'pgSz', to: :page_size
        map_element 'pgMar', to: :page_margins
        map_element 'pgBorders', to: :page_borders
        map_element 'lnNumType', to: :line_numbering
        map_element 'pgNumType', to: :page_numbering
        map_element 'cols', to: :columns
        map_element 'formProt', to: :form_protection
        map_element 'vAlign', to: :vertical_alignment
        map_element 'noEndnote', to: :no_endnote
        map_element 'titlePg', to: :title_page
        map_element 'textDirection', to: :text_direction
        map_element 'bidi', to: :bidirectional
        map_element 'rtlGutter', to: :rtl_gutter
        map_element 'docGrid', to: :document_grid
      end

      # Footnote properties for the section
      attribute :footnote_properties, :string

      # Endnote properties for the section
      attribute :endnote_properties, :string

      # Section type (nextPage, nextColumn, continuous, evenPage, oddPage)
      # - nextPage: Start new page
      # - nextColumn: Start new column
      # - continuous: Continuous with previous section
      # - evenPage: Start on next even page
      # - oddPage: Start on next odd page
      attribute :section_type, :string

      # Page size properties
      attribute :page_size, :string

      # Page margins
      attribute :page_margins, :string

      # Page borders
      attribute :page_borders, :string

      # Line numbering properties
      attribute :line_numbering, :string

      # Page numbering properties
      attribute :page_numbering, :string

      # Column properties
      attribute :columns, :string

      # Form protection for the section
      attribute :form_protection, :boolean, default: -> { false }

      # Vertical alignment (top, center, both, bottom)
      attribute :vertical_alignment, :string

      # No endnote in this section
      attribute :no_endnote, :boolean, default: -> { false }

      # Different first page header/footer
      attribute :title_page, :boolean, default: -> { false }

      # Text direction (lrTb, tbRl, btLr, lrTbV, tbRlV, tbLrV)
      attribute :text_direction, :string

      # Bidirectional text
      attribute :bidirectional, :boolean, default: -> { false }

      # RTL gutter (for right-to-left documents)
      attribute :rtl_gutter, :boolean, default: -> { false }

      # Document grid properties (for Asian text layout)
      attribute :document_grid, :string

      # Convenience method to create a continuous section break
      def self.continuous
        new(section_type: 'continuous')
      end

      # Convenience method to create a new page section break
      def self.new_page
        new(section_type: 'nextPage')
      end

      # Convenience method to create a new column section break
      def self.new_column
        new(section_type: 'nextColumn')
      end

      # Convenience method to create an even page section break
      def self.even_page
        new(section_type: 'evenPage')
      end

      # Convenience method to create an odd page section break
      def self.odd_page
        new(section_type: 'oddPage')
      end

      # Check if this is a continuous section
      def continuous?
        section_type == 'continuous'
      end

      # Check if this starts a new page
      def new_page?
        section_type == 'nextPage'
      end

      # Check if this starts a new column
      def new_column?
        section_type == 'nextColumn'
      end

      # Check if this starts on an even page
      def even_page?
        section_type == 'evenPage'
      end

      # Check if this starts on an odd page
      def odd_page?
        section_type == 'oddPage'
      end

      # Check if this has a title page (different first page header/footer)
      def title_page?
        title_page
      end

      # Check if this has form protection
      def form_protected?
        form_protection
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        footnote_properties == other.footnote_properties &&
          endnote_properties == other.endnote_properties &&
          section_type == other.section_type &&
          page_size == other.page_size &&
          page_margins == other.page_margins &&
          page_borders == other.page_borders &&
          line_numbering == other.line_numbering &&
          page_numbering == other.page_numbering &&
          columns == other.columns &&
          form_protection == other.form_protection &&
          vertical_alignment == other.vertical_alignment &&
          no_endnote == other.no_endnote &&
          title_page == other.title_page &&
          text_direction == other.text_direction &&
          bidirectional == other.bidirectional &&
          rtl_gutter == other.rtl_gutter &&
          document_grid == other.document_grid
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [footnote_properties, endnote_properties, section_type, page_size, page_margins,
         page_borders, line_numbering, page_numbering, columns, form_protection,
         vertical_alignment, no_endnote, title_page, text_direction, bidirectional,
         rtl_gutter, document_grid].hash
      end
    end
  end
end