# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Relationships
      # Package-level Relationships root element (for _rels/.rels)
      #
      # Uses package namespace: http://schemas.openxmlformats.org/package/2006/relationships
      class PackageRelationships < Lutaml::Model::Serializable
        attribute :relationships, PackageRelationship, collection: true,
                                                       initialize_empty: true

        xml do
          element "Relationships"
          namespace Uniword::Ooxml::Namespaces::PackageRelationships
          ordered

          map_element "Relationship", to: :relationships, render_nil: false
        end

        # Generates relationship files (.rels) for DOCX packages
        #
        # Generate package-level .rels file
        #
        # @return [PackageRelationships] Relationships object for _rels/.rels
        def self.generate_package_rels
          new(
            relationships: [
              PackageRelationship.new(
                id: "rId3",
                type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties",
                target: "docProps/app.xml",
              ),
              PackageRelationship.new(
                id: "rId2",
                type: "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties",
                target: "docProps/core.xml",
              ),
              PackageRelationship.new(
                id: "rId1",
                type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
                target: "word/document.xml",
              ),
            ],
          )
        end
      end
    end
  end
end
