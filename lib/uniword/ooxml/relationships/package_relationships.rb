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

          map_element "Relationship", to: :relationships, render_nil: false
        end

        # Generates relationship files (.rels) for DOCX packages
        #
        # Generate package-level .rels file
        #
        # Historical rId assignment: rId3 = app, rId2 = core,
        # rId1 = document (kept for byte-identical DOTX output).
        #
        # @return [PackageRelationships] Relationships object for _rels/.rels
        def self.next_available_rid(relationships)
          max = relationships.relationships.filter_map do |r|
            r.id[/\ArId(\d+)\z/, 1]&.to_i
          end.max || 0
          "rId#{max + 1}"
        end

        def self.generate_package_rels
          new(
            relationships: [
              package_relationship("rId3", :app_properties),
              package_relationship("rId2", :core_properties),
              package_relationship("rId1", :document),
            ],
          )
        end

        # Build one package-level relationship from the registry.
        #
        # @param rid [String] relationship ID
        # @param key [Symbol] PartRegistry key
        # @return [PackageRelationship]
        def self.package_relationship(rid, key)
          definition = PartRegistry.find_by_key(key)
          PackageRelationship.new(
            id: rid,
            type: definition.rel_type,
            target: definition.target,
          )
        end
      end
    end
  end
end
