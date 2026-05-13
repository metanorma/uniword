# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Footnotes collection
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:footnotes>
    class Footnotes < Lutaml::Model::Serializable
      attribute :footnote_entries, Footnote, collection: true,
                                             initialize_empty: true

      xml do
        element "footnotes"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "footnote", to: :footnote_entries, render_nil: false
      end

      def sync_element_order
        return if element_order.nil? || element_order.empty?

        counts = element_order.each_with_object(Hash.new(0)) do |e, h|
          h[e.name] += 1
        end

        missing = footnote_entries.size - counts["footnote"]
        missing.times do
          element_order << Lutaml::Xml::Element.new("Element", "footnote")
        end
      end

      def to_xml(options = {})
        sync_element_order
        super
      end
    end
  end
end
