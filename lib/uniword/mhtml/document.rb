# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    # MHTML-specific Document class
    #
    # This is SEPARATE from OOXML WordprocessingML DocumentRoot.
    # MHTML documents use HTML structure, not OOXML document.xml.
    #
    # This class represents an MHTML document with HTML content
    # and associated resources.
    class Document < Lutaml::Model::Serializable
      attribute :html_content, :string
      attribute :title, :string
      attribute :styles, :string
      attribute :elements, :array, default: -> { [] }

      # MHTML-specific metadata
      attribute :core_properties, :hash, default: -> { {} }
      attribute :app_properties, :hash, default: -> { {} }

      # MHTML-specific: Get raw HTML
      #
      # @return [String, nil] Raw HTML content
      def raw_html
        html_content
      end

      # MHTML-specific: Set raw HTML
      #
      # @param value [String] HTML content
      def raw_html=(value)
        self.html_content = value
      end

      # MHTML-specific: Convert to full HTML document
      #
      # @return [String] Complete HTML document
      def to_html_document
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>#{title || 'Document'}</title>
            <style>
          #{styles}
            </style>
          </head>
          <body>
          #{html_content}
          </body>
          </html>
        HTML
      end
    end
  end
end
