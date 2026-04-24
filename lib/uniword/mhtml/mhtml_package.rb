# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Mhtml
    # MHTML Package — MIME-based Word format (.mht, .mhtml, .doc).
    #
    # IMPORTANT: This is COMPLETELY SEPARATE from OOXML Docx::Package.
    # - OOXML uses ZIP + XML parts
    # - MHTML uses MIME + HTML content
    # - They share NO classes!
    #
    # @example Load MHTML file
    #   document = MhtmlPackage.from_file('document.mhtml')
    #
    # @example Save MHTML file
    #   MhtmlPackage.to_file(document, 'output.doc')
    class MhtmlPackage < Lutaml::Model::Serializable
      attribute :core_properties, :hash, default: -> { {} }
      attribute :app_properties, :hash, default: -> { {} }
      attribute :theme, Theme
      attribute :styles_configuration, StylesConfiguration
      attribute :numbering_configuration, NumberingConfiguration

      # Legacy accessors for backward compatibility
      attr_accessor :raw_html_content
      attr_accessor :filelist_xml, :images

      # Load MHTML file and return a populated Document model.
      #
      # @param path [String] Path to .mht, .mhtml, or .doc file
      # @return [Document] Loaded document with all MIME parts
      def self.from_file(path)
        parser = Infrastructure::MimeParser.new
        parser.parse(path)
      end

      # Save MHTML Document to file.
      #
      # @param document [Document, Wordprocessingml::DocumentRoot] The document to save
      # @param path [String] Output path
      def self.to_file(document, path)
        # Convert OOXML DocumentRoot to Mhtml::Document if needed
        document = Transformation::Transformer.new.docx_to_mhtml(document) if document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        packager = Infrastructure::MimePackager.from_document(document)
        packager.package(path)
      end

      def self.supported_extensions
        [".mht", ".mhtml", ".doc"]
      end

      # Legacy compatibility: convert to MIME parts hash
      def to_mime_parts
        {
          "html" => raw_html_content,
          "filelist" => filelist_xml,
          "images" => images || {},
        }
      end
    end
  end
end
