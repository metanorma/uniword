# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Drawing container
    # Contains either Inline (inline with text) or Anchor (positioned/floating)
    class Drawing < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :inline, WpDrawing::Inline
      attribute :anchor, WpDrawing::Anchor

      xml do
        element "drawing"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "inline", to: :inline, render_nil: false
        map_element "anchor", to: :anchor, render_nil: false
      end

      # Alternative text for the drawing.
      #
      # Alt text lives in the descr attribute of wp:docPr. ECMA-376 names
      # descr the description of the object; title is the object's caption,
      # which Word's modern Alt Text pane does not write and screen readers
      # do not announce. Word documents in the ISO corpus carry their alt
      # text in descr with no title at all, so title is deliberately not a
      # fallback here — see #alt_title.
      #
      # CT_Drawing is a choice over wp:inline and wp:anchor, so a drawing may
      # carry either or both. Take the first frame supplying a non-blank
      # description. Surrounding whitespace is not description, so the value
      # is stripped and a blank one counts as absent.
      #
      # @return [String, nil] Alternative text, or nil when absent
      def alt_text
        first_non_blank(:descr)
      end

      # Set the alternative text on whichever frame this drawing carries.
      # A drawing with neither frame has nowhere to put it.
      #
      # @param text [String, nil] Alternative text
      def alt_text=(text)
        frame = inline || anchor
        unless frame.nil?
          frame.doc_properties ||= WpDrawing::DocProperties.new
          frame.doc_properties.descr = text
        end
      end

      # The drawing's title (Word's legacy "Title" field), which is a caption
      # rather than a text alternative. Reported so a rule can tell an author
      # that their description is sitting in the wrong field.
      #
      # @return [String, nil] Title, or nil when absent
      def alt_title
        first_non_blank(:title)
      end

      private

      # @param attribute [Symbol] docPr attribute to read
      # @return [String, nil] First non-blank value across the frames
      def first_non_blank(attribute)
        [inline, anchor]
          .filter_map { |frame| frame&.doc_properties&.public_send(attribute) }
          .map(&:strip)
          .find { |text| !text.empty? }
      end
    end
  end
end
