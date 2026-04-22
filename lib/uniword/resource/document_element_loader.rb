# frozen_string_literal: true

require "yaml"

module Uniword
  module Resource
    # Loads document element templates from data/resources/document_elements/
    class DocumentElementLoader
      DATA_DIR = File.join(__dir__, "../../../data/resources/document_elements")

      # Load templates for a specific locale and category
      #
      # @param locale [String] Locale code (e.g., "en", "ja", "zh-CN")
      # @param category [String] Category slug (e.g., "cover_pages", "headers")
      # @return [DocumentElementTemplate] The loaded template collection
      # @raise [ArgumentError] if locale/category not found
      def self.load(locale, category)
        path = File.join(DATA_DIR, locale, "#{category}.yml")
        unless File.exist?(path)
          raise ArgumentError,
                "Document elements not found: #{locale}/#{category}. " \
                "Available locales: #{available_locales.join(", ")}"
        end

        data = YAML.load_file(path)
        DocumentElementTemplate.from_hash(data)
      end

      # List available categories for a locale
      #
      # @param locale [String] Locale code
      # @return [Array<String>] Category slugs
      def self.available_categories(locale)
        dir = File.join(DATA_DIR, locale)
        return [] unless Dir.exist?(dir)

        Dir.glob(File.join(dir, "*.yml"))
           .map { |p| File.basename(p, ".yml") }
           .sort
      end

      # List all available locales
      #
      # @return [Array<String>] Locale codes
      def self.available_locales
        return [] unless Dir.exist?(DATA_DIR)

        Dir.glob(File.join(DATA_DIR, "*/"))
           .map { |p| File.basename(p) }
           .sort
      end
    end
  end
end
