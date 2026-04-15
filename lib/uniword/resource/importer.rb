# frozen_string_literal: true

module Uniword
  module Resource
    # MODEL for importing resources from Word or files
    #
    # Has state (word/cache references) and behavior (import_one, import_all)
    # Does NOT extend Lutaml::Model::Serializable
    class Importer
      attr_reader :word, :cache

      # Initialize importer with dependencies
      #
      # @param word [WordImplementation] Word implementation instance
      # @param cache [Cache] Cache instance
      def initialize(word, cache)
        @word = word
        @cache = cache
      end

      # Import a single resource by name
      #
      # @param type [Symbol] Resource type (:theme, :styleset, :color_scheme, :font_scheme)
      # @param name [String] Resource name
      # @return [Object] The imported resource
      # @raise [ArgumentError] if Word not installed or resource not found
      def import_one(type, name)
        raise ArgumentError, "Microsoft Word is not installed" unless word.installed?

        resource = load_from_word(type, name)
        cache.write(type, name, resource.to_yaml)
        resource
      end

      # Import all resources of a type
      #
      # @param type [Symbol] Resource type
      # @param force [Boolean] Overwrite existing cache entries
      # @return [Integer] Number of resources imported
      def import_all_of_type(type, force: false)
        raise ArgumentError, "Microsoft Word is not installed" unless word.installed?

        available = available_resources(type)
        count = 0

        available.each do |name|
          next if !force && cache.exists?(type, name)

          begin
            import_one(type, name)
            count += 1
          rescue StandardError => e
            warn "Failed to import #{type} '#{name}': #{e.message}"
          end
        end

        count
      end

      # Import all resources from Word
      #
      # @param force [Boolean] Overwrite existing cache entries
      # @return [Hash] Count of imported resources by type
      def import_all(force: false)
        result = {}

        %i[theme styleset].each do |type|
          result[type] = import_all_of_type(type, force: force)
        end

        result
      end

      private

      # Load resource from Word installation
      #
      # @param type [Symbol] Resource type
      # @param name [String] Resource name
      # @return [Object] Loaded resource
      def load_from_word(type, name)
        case type
        when :theme
          path = File.join(word.themes_path, "#{name}.thmx")
          raise ArgumentError, "Theme not found: #{name}" unless File.exist?(path)

          Uniword::Ooxml::ThmxPackage.from_file(path)&.theme
        when :styleset
          path = File.join(word.stylesets_path, "#{name}.dotx")
          raise ArgumentError, "StyleSet not found: #{name}" unless File.exist?(path)

          Uniword::Ooxml::DotxPackage.from_file(path)&.styles_configuration
        else
          raise ArgumentError, "Unsupported resource type: #{type}"
        end
      end

      # Get list of available resources from Word
      #
      # @param type [Symbol] Resource type
      # @return [Array<String>] Available resource names
      def available_resources(type)
        case type
        when :theme
          word.available_themes
        when :styleset
          word.available_stylesets
        else
          []
        end
      end
    end
  end
end
