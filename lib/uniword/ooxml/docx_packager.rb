# frozen_string_literal: true

require_relative '../infrastructure/zip_packager'
require_relative 'content_types'
require_relative 'relationships'

module Uniword
  module Ooxml
    # Packages OOXML content into a DOCX file
    class DocxPackager
      # Package a document into a DOCX file
      #
      # @param document_xml [String] The serialized document.xml content
      # @param output_path [String] The output DOCX file path
      # @return [void]
      def self.package(document_xml, output_path)
        content = {
          '[Content_Types].xml' => ContentTypes.generate,
          '_rels/.rels' => Relationships.generate_package_rels,
          'word/document.xml' => document_xml,
          'word/_rels/document.xml.rels' => Relationships.generate_document_rels
        }

        packager = Infrastructure::ZipPackager.new
        packager.package(content, output_path)
      end
    end
  end
end