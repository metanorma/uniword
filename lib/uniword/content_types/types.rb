# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module ContentTypes
    # Content types root element for [Content_Types].xml
    #
    # Generated from OOXML schema: content_types.yml
    # Element: <ct:Types>
    class Types < Lutaml::Model::Serializable
      attribute :defaults, Default, collection: true, initialize_empty: true
      attribute :overrides, Override, collection: true, initialize_empty: true

      xml do
        element "Types"
        namespace Uniword::Ooxml::Namespaces::ContentTypes
        map_element "Default", to: :defaults, render_nil: false
        map_element "Override", to: :overrides, render_nil: false
      end

      # Resolve the content type declared for a package-relative path.
      #
      # Override entries win; the Default extension match is the
      # fallback. Returns nil when neither matches (the part is
      # non-compliant per OPC).
      #
      # @param path [String] package-relative path (e.g.
      #   "word/document.xml")
      # @return [String, nil] content type, or nil when undeclared
      def content_type_for(path)
        override_content_type(path) || default_content_type(path)
      end

      private

      def override_content_type(path)
        part_name = "/#{path}"
        overrides.find { |o| o.part_name == part_name }&.content_type
      end

      def default_content_type(path)
        ext = File.extname(path)[1..]
        return nil unless ext

        defaults.find { |d| d.extension == ext }&.content_type
      end
    end
  end
end
