# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Endnotes collection
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:endnotes>
    class Endnotes < Lutaml::Model::Serializable
      attribute :endnote_entries, Endnote, collection: true,
                                           initialize_empty: true

      xml do
        element "endnotes"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "endnote", to: :endnote_entries, render_nil: false
      end

      def sync_element_order
        return if element_order.nil? || element_order.empty?

        counts = element_order.each_with_object(Hash.new(0)) do |e, h|
          h[e.name] += 1
        end

        missing = endnote_entries.size - counts["endnote"]
        missing.times do
          element_order << Lutaml::Xml::Element.new("Element", "endnote")
        end
      end

      def to_xml(options = {})
        sync_element_order
        super
      end
    end
  end
end
