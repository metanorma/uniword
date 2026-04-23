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
    # Generate comprehensive [Content_Types].xml
    #
    # @return [Types] Content types object
    def generate
      Types.new(
        defaults: [
          Default.new(extension: "jpeg",
                      content_type: "image/jpeg"),
          Default.new(extension: "png",
                      content_type: "image/png"),
          Default.new(extension: "gif",
                      content_type: "image/gif"),
          Default.new(extension: "rels",
                      content_type: "application/vnd.openxmlformats-package.relationships+xml"),
          Default.new(extension: "xml",
                      content_type: "application/xml"),
        ],
        overrides: [
          Override.new(part_name: "/word/document.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"),
          Override.new(part_name: "/word/numbering.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"),
          Override.new(part_name: "/word/styles.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"),
          Override.new(part_name: "/word/settings.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"),
          Override.new(part_name: "/word/webSettings.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml"),
          Override.new(part_name: "/word/fontTable.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"),
          Override.new(part_name: "/word/theme/theme1.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.theme+xml"),
          Override.new(part_name: "/docProps/core.xml",
                       content_type: "application/vnd.openxmlformats-package.core-properties+xml"),
          Override.new(part_name: "/docProps/app.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.extended-properties+xml"),
        ],
      )
    end
    module_function :generate

    # Generate [Content_Types].xml for THMX (theme) packages
    #
    # @return [Types] Content types object for theme package
    def generate_for_theme
      Types.new(
        defaults: [
          Default.new(extension: "rels",
                      content_type: "application/vnd.openxmlformats-package.relationships+xml"),
          Default.new(extension: "xml", content_type: "application/xml"),
        ],
        overrides: [
          Override.new(part_name: "/theme/theme1.xml",
                       content_type: "application/vnd.openxmlformats-officedocument.theme+xml"),
        ],
      )
    end
    module_function :generate_for_theme
  end
end
