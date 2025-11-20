# frozen_string_literal: true

module Uniword
  module Ooxml
    # Generates [Content_Types].xml for DOCX packages
    # This file tells Office what kind of content each part contains
    class ContentTypes
      # Generate minimal [Content_Types].xml
      #
      # @return [String] XML content
      def self.generate
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
            <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
            <Default Extension="xml" ContentType="application/xml"/>
            <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
          </Types>
        XML
      end
    end
  end
end