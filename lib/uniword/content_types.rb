# frozen_string_literal: true

# Content Types namespace
# MIME type definitions for OOXML package parts
# Namespace: http://schemas.openxmlformats.org/package/2006/content-types
# Prefix: ct: (but typically no prefix, used in [Content_Types].xml)

module Uniword
  module ContentTypes
    autoload :Default, "#{__dir__}/content_types/default"
    autoload :Override, "#{__dir__}/content_types/override"
    autoload :Types, "#{__dir__}/content_types/types"

    # Generates [Content_Types].xml for DOCX packages
    # This content tells Office what kind of content each part contains
    #
    # Generate minimal [Content_Types].xml
    #
    # @return [Types] Content types object
    def generate
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
    def generate_for_theme
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
