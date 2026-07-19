# frozen_string_literal: true

module Uniword
  module Docx
    # Factory methods and defaults for DOCX package construction.
    #
    # Extracted from Package for separation of responsibilities.
    # Included in Package for backward compatibility.
    #
    # @api private
    module PackageDefaults
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class methods for package construction
      module ClassMethods
        # Part kinds in a minimal [Content_Types].xml, emission order.
        MINIMAL_CT_DEFAULT_PARTS = %i[rels xml].freeze
        MINIMAL_CT_OVERRIDE_PARTS =
          %i[document styles font_table settings web_settings
             app_properties core_properties].freeze

        # Part kinds in a minimal _rels/.rels, in rId order.
        MINIMAL_PACKAGE_REL_PARTS =
          %i[document core_properties app_properties].freeze

        # Part kinds in a minimal word/_rels/document.xml.rels,
        # in rId order.
        MINIMAL_DOCUMENT_REL_PARTS =
          %i[styles settings web_settings font_table].freeze

        # Copy parts from document to package for round-trip preservation
        #
        # Registry-driven: every PartDefinition naming both a document
        # and a package attribute is mirrored, honoring the
        # definition's optional +to_package_guard+ predicate (e.g. the
        # lazily-initialized numbering configuration) and
        # +to_package_type+ value constraint (e.g. comments).
        def copy_document_parts_to_package(document, package)
          return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

          Ooxml::PartRegistry.copied_to_package.each do |definition|
            copy_part_to_package(document, package, definition)
          end

          package.allocator = document.allocator if document.allocator
        end

        # Create minimal content types for a valid DOCX
        def minimal_content_types
          ct = Uniword::ContentTypes::Types.new
          ct.defaults = MINIMAL_CT_DEFAULT_PARTS.map do |key|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Uniword::ContentTypes::Default.new(
              extension: defn.extension,
              content_type: defn.content_type,
            )
          end
          ct.overrides = MINIMAL_CT_OVERRIDE_PARTS.map do |key|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Uniword::ContentTypes::Override.new(
              part_name: defn.part_name,
              content_type: defn.content_type,
            )
          end
          ct
        end

        # Create minimal package relationships for a valid DOCX
        def minimal_package_rels
          build_minimal_rels(MINIMAL_PACKAGE_REL_PARTS)
        end

        # Create minimal document relationships for a valid DOCX
        def minimal_document_rels
          build_minimal_rels(MINIMAL_DOCUMENT_REL_PARTS)
        end

        private

        # Copy one document part to the package when the definition's
        # guard predicate and value type constraint allow it.
        def copy_part_to_package(document, package, definition)
          return unless copyable_to_package?(document, definition)

          value = document.method(definition.document_attribute).call
          return if value.nil?
          return unless copyable_type?(definition, value)

          package.method(:"#{definition.package_attribute}=").call(value)
        end

        # The guard predicate named by the definition (a method on the
        # document, e.g. :numbering_configuration_loaded?) decides;
        # without a guard the part copies.
        def copyable_to_package?(document, definition)
          guard = definition.to_package_guard
          guard.nil? || document.method(guard).call
        end

        # When the definition constrains the value type (e.g.
        # CommentsPart for comments), the value must satisfy it.
        def copyable_type?(definition, value)
          type = definition.to_package_type
          type.nil? || value.is_a?(type)
        end

        # Build a Relationships part with sequential rIds (rId1..rIdN)
        # for the given registry part keys, in the given order.
        def build_minimal_rels(part_keys)
          rels = Ooxml::Relationships::PackageRelationships.new
          rels.relationships = part_keys.each_with_index.map do |key, idx|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Ooxml::Relationships::Relationship.new(
              id: "rId#{idx + 1}",
              type: defn.rel_type,
              target: defn.target,
            )
          end
          rels
        end
      end
    end
  end
end
