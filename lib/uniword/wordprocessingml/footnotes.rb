# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Footnotes collection
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:footnotes>
    class Footnotes < Lutaml::Model::Serializable
      attribute :mc_ignorable, Uniword::Ooxml::Types::McIgnorable
      attribute :footnote_entries, Footnote, collection: true,
                                             initialize_empty: true

      xml do
        element "footnotes"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        namespace_scope Uniword::Ooxml::Namespaces::DOCUMENT_PART_SCOPES

        map_attribute "Ignorable", to: :mc_ignorable, render_nil: false
        map_element "footnote", to: :footnote_entries, render_nil: false
      end

      def sync_element_order
        return if element_order.nil? || element_order.empty?

        counts = element_order.each_with_object(Hash.new(0)) do |e, h|
          h[e.name] += 1
        end

        missing = footnote_entries.size - counts["footnote"]
        return unless missing.positive?

        # element_order from the parser may be frozen; never mutate it.
        self.element_order = element_order.dup
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
