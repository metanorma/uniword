# frozen_string_literal: true

# Content Types namespace
# MIME type definitions for OOXML package parts
# Namespace: http://schemas.openxmlformats.org/package/2006/content-types
# Prefix: ct: (but typically no prefix, used in [Content_Types].xml)

module Uniword
  module ContentTypes
    autoload :Default, File.expand_path('content_types/default', __dir__)
    autoload :Override, File.expand_path('content_types/override', __dir__)
    autoload :Types, File.expand_path('content_types/types', __dir__)

    # Generates [Content_Types].xml for DOCX packages
    # This content tells Office what kind of content each part contains
    #
    # Generate minimal [Content_Types].xml
    #
    # @return [String] XML content
    def self.generate
      Types.new(
        defaults: [
          Default.new(extension: 'rels',
                      content_type: 'application/vnd.openxmlformats-package.relationships+xml'),
          Default.new(extension: 'xml', content_type: 'application/xml')
        ],
        overrides: [
          Override.new(part_name: '/word/document.xml',
                       content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml')
        ]
      )
    end
    module_function :generate

    # Generate [Content_Types].xml for THMX (theme) packages
    #
    # @return [Types] Content types object for theme package
    def self.generate_for_theme
      Types.new(
        defaults: [
          Default.new(extension: 'rels',
                      content_type: 'application/vnd.openxmlformats-package.relationships+xml'),
          Default.new(extension: 'xml', content_type: 'application/xml')
        ],
        overrides: [
          Override.new(part_name: '/theme/theme1.xml',
                       content_type: 'application/vnd.openxmlformats-officedocument.theme+xml')
        ]
      )
    end
    module_function :generate_for_theme
  end
end
