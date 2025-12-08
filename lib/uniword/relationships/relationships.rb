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

      # Generate theme package-level .rels file
      #
      # @return [Relationships] Relationships object for _rels/.rels in theme package
      def self.generate_theme_package_rels
        new(
          relationships: [
            Relationship.new(
              id: 'rId1',
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme',
              target: 'theme/theme1.xml'
            )
          ]
        )
      end

      # Generate theme-level .rels file
      #
      # @return [Relationships] Relationships object for theme/_rels/theme1.xml.rels
      def self.generate_theme_rels
        new(
          relationships: []
        )
      end

    end
  end
end
