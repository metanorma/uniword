# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Hyperlink element
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:hyperlink>
    class Hyperlink < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :anchor, :string
      attribute :tooltip, :string
      attribute :history, Uniword::Properties::HistoryValue
      attribute :runs, Run, collection: true, initialize_empty: true

      xml do
        element "hyperlink"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "id", to: :id
        map_attribute "anchor", to: :anchor
        map_attribute "tooltip", to: :tooltip
        map_attribute "history", to: :history
        map_element "r", to: :runs, render_nil: false
      end

      # Set hyperlink target (convenience method)
      # Automatically determines if target is external (URL) or internal (bookmark)
      #
      # @param value [String] URL or bookmark target
      # @return [self] For method chaining
      def target=(value)
        if value.to_s.start_with?("#")
          # Internal bookmark link
          self.anchor = value.sub(/^#/, "")
        else
          # External URL link (stored in r:id via relationships)
          self.id = value
        end
        self
      end

      # Get hyperlink target (convenience method)
      #
      # @return [String, nil] URL or bookmark target
      def target
        anchor ? "##{anchor}" : id
      end

      # Get URL (convenience method)
      #
      # @return [String, nil] The URL if external link
      def url
        id
      end

      # Check if hyperlink is internal
      #
      # @return [Boolean] true if anchor is set (internal link)
      def internal?
        !anchor.nil?
      end

      # Check if hyperlink is external
      #
      # @return [Boolean] true if id is set (external link)
      def external?
        !id.nil? && anchor.nil?
      end
    end
  end
end
