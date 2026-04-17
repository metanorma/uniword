# frozen_string_literal: true

module Uniword
  module Resource
    # Represents a collection of document element templates for a locale/category.
    #
    # Document elements are reusable building blocks (cover pages, headers,
    # footers, etc.) defined as human-readable YAML templates.
    class DocumentElementTemplate
      attr_reader :locale, :category, :description, :elements

      # Create a new template collection
      #
      # @param locale [String] Locale code (e.g., "en", "ja", "zh-CN")
      # @param category [String] Category slug (e.g., "cover_pages", "headers")
      # @param description [String] Description of this template collection
      # @param elements [Array<Hash>] Array of element definitions
      def initialize(locale:, category:, description: "", elements: [])
        @locale = locale
        @category = category
        @description = description
        @elements = elements
      end

      # Load from parsed YAML hash
      #
      # @param data [Hash] Parsed YAML data
      # @return [DocumentElementTemplate]
      def self.from_hash(data)
        new(
          locale: data["locale"],
          category: data["category"],
          description: data["description"] || "",
          elements: data["elements"] || []
        )
      end

      # Find element by name
      #
      # @param name [String] Element name
      # @return [Hash, nil] Element definition
      def find_element(name)
        elements.find { |e| e["name"] == name }
      end

      # List element names
      #
      # @return [Array<String>] Element names
      def element_names
        elements.map { |e| e["name"] }
      end
    end
  end
end
