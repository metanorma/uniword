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

      def target
        anchor ? "##{anchor}" : id
      end

      def target=(value)
        if value.to_s.start_with?("#")
          self.anchor = value.sub(/^#/, "")
        else
          self.id = value
        end
      end

      def url
        id
      end

      def internal?
        !anchor.nil?
      end

      def external?
        !id.nil? && anchor.nil?
      end
    end
  end
end
