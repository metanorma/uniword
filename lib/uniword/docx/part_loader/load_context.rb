# frozen_string_literal: true

module Uniword
  module Docx
    class PartLoader
      # Shared state for one package load: the extracted ZIP entries,
      # the package being populated, and the main-document paths
      # resolved from the package-level relationships.
      class LoadContext
        # @return [Hash] extracted ZIP entries (package path => content)
        attr_reader :zip_content

        # @return [Package] package being populated
        attr_reader :package

        # @return [String, nil] original ZIP path for binary
        #   re-extraction
        attr_reader :zip_path

        # @param zip_content [Hash] extracted ZIP entries
        # @param package [Package] package being populated
        # @param zip_path [String, nil] original ZIP path
        def initialize(zip_content:, package:, zip_path: nil)
          @zip_content = zip_content
          @package = package
          @zip_path = zip_path
        end

        # Zip entry paths matching the definition's fixed path or
        # path pattern (numbered part families).
        #
        # @param definition [Ooxml::PartDefinition]
        # @return [Array<String>] in zip_content order
        def matching_paths(definition)
          zip_content.keys.select { |path| definition.match_path?(path) }
        end

        # Main document part path, resolved from the package-level
        # officeDocument relationship.
        #
        # @return [String, nil] e.g. "word/document.xml"
        def main_document_path
          return @main_document_path if defined?(@main_document_path)

          @main_document_path = find_main_document_path
        end

        # Relationships part path of the main document, derived from
        # its resolved path.
        #
        # @return [String, nil] e.g. "word/_rels/document.xml.rels"
        def main_document_rels_path
          return @main_document_rels_path if defined?(@main_document_rels_path)

          @main_document_rels_path = sidecar_rels_path(main_document_path)
        end

        private

        def find_main_document_path
          relationships = package.package_rels&.relationships
          return nil unless relationships

          office_document = Ooxml::PartRegistry.find_by_key(:document).rel_type
          rel = relationships.find do |r|
            r.type.to_s.include?(office_document)
          end
          return nil unless rel&.target

          rel.target.dup.delete_prefix("/")
        end

        # OPC relationships sidecar: sibling "_rels" directory named
        # after the part ("word/document.xml" →
        # "word/_rels/document.xml.rels").
        def sidecar_rels_path(part_path)
          return nil unless part_path

          File.join(File.dirname(part_path), "_rels",
                    "#{File.basename(part_path)}.rels")
        end
      end
    end
  end
end
