# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Relationships
      # Document-level Relationships root element (for word/_rels/document.xml.rels)
      #
      # Uses officeDocument namespace: http://schemas.openxmlformats.org/officeDocument/2006/relationships
      # Attributes are prefixed with r: (r:id, r:type, r:target)
      class Relationships < Lutaml::Model::Serializable
        attribute :relationships, Relationship, collection: true,
                                                initialize_empty: true

        xml do
          element "Relationships"
          namespace Uniword::Ooxml::Namespaces::Relationships
          mixed_content

          map_element "Relationship", to: :relationships, render_nil: false
        end

        # Generate document-level .rels file
        #
        # @return [Relationships] Relationships object for word/_rels/document.xml.rels
        def self.generate_document_rels
          new(
            relationships: [],
          )
        end

        # Generate theme-level .rels file
        #
        # @return [Relationships] Relationships object for theme/_rels/theme1.xml.rels
        def self.generate_theme_rels
          new(
            relationships: [],
          )
        end
      end
    end
  end
end
