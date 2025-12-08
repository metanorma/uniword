# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Relationships
    # Relationships root element
    #
    # Generated from OOXML schema: relationships.yml
    # Element: <r:Relationships>
    class Relationships < Lutaml::Model::Serializable
      attribute :relationships, Relationship, collection: true, default: -> { [] }

      xml do
        element 'Relationships'
        namespace Uniword::Ooxml::Namespaces::Relationships
        mixed_content

        map_element 'Relationship', to: :relationships, render_nil: false
      end

      # Generates relationship files (.rels) for DOCX packages
      #
      # Generate package-level .rels file
      #
      # @return [String] XML content for _rels/.rels
      def self.generate_package_rels
        new(
          relationships: [
            Relationship.new(
              id: 'rId1',
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument',
              target: 'word/document.xml'
            )
          ]
        )
      end

      # Generate document-level .rels file
      #
      # @return [String] XML content for word/_rels/document.xml.rels
      def self.generate_document_rels
        new(
          relationships: []
        )
      end

    end
  end
end
