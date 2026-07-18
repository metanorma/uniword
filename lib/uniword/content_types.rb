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
    # Derived from Ooxml::PartRegistry (:standard definitions, in
    # registration order — historically the literal order below).
    #
    # @return [Types] Content types object
    def generate
      Types.new(
        defaults: Ooxml::PartRegistry.standard_defaults.map do |defn|
          Default.new(extension: defn.extension,
                      content_type: defn.content_type)
        end,
        overrides: Ooxml::PartRegistry.standard_overrides.map do |defn|
          Override.new(part_name: defn.part_name,
                       content_type: defn.content_type)
        end,
      )
    end
    module_function :generate

    # Generate [Content_Types].xml for THMX (theme) packages
    #
    # @return [Types] Content types object for theme package
    def generate_for_theme
      theme = Ooxml::PartRegistry.find_by_key(:thmx_theme)
      Types.new(
        defaults: %i[rels xml].map do |key|
          defn = Ooxml::PartRegistry.find_by_key(key)
          Default.new(extension: defn.extension,
                      content_type: defn.content_type)
        end,
        overrides: [
          Override.new(part_name: theme.part_name,
                       content_type: theme.content_type),
        ],
      )
    end
    module_function :generate_for_theme
  end
end
