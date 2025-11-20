# frozen_string_literal: true

module Uniword
  module Ooxml
    # Generates relationship files (.rels) for DOCX packages
    class Relationships
      # Generate package-level .rels file
      #
      # @return [String] XML content for _rels/.rels
      def self.generate_package_rels
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
          </Relationships>
        XML
      end

      # Generate document-level .rels file
      #
      # @return [String] XML content for word/_rels/document.xml.rels
      def self.generate_document_rels
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          </Relationships>
        XML
      end
    end
  end
end