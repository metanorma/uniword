# frozen_string_literal: true

# Serialization infrastructure for Uniword documents
module Uniword
  module Serialization
    # OOXML Serializer for Uniword documents
    #
    # Serializes Uniword documents to XML format using lutaml-model.
    # Note: This class is a placeholder for the serialization API.
    # The actual serialization is done by DocxPackage.to_file which
    # handles the complete package serialization including all XML parts.
    class OoxmlSerializer
      # Serialize a document to XML
      #
      # @param document [DocumentRoot] The document to serialize
      # @return [String] The serialized XML
      def serialize(document)
        document.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
      end

      # Serialize a document to XML and return as a Nokogiri document
      #
      # @param document [DocumentRoot] The document to serialize
      # @return [Nokogiri::XML::Document] The serialized document
      def serialize_to_doc(document)
        Nokogiri::XML(serialize(document))
      end
    end
  end
end
