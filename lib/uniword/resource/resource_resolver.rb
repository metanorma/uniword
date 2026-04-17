# frozen_string_literal: true

module Uniword
  module Resource
    # MODEL for resolving resources from multiple sources
    # Has state (cache reference) and behavior (resolve, list)
    #
    # Does NOT extend Lutaml::Model::Serializable.
    class ResourceResolver
      # Resolution order: cached -> bundled
      RESOLUTION_ORDER = %i[cached bundled].freeze

      attr_reader :cache

      def initialize(cache = nil)
        @cache = cache || Cache.new
      end

      # Resolve resource by name
      # Returns ResourceLocation or nil if not found
      def resolve(type, name)
        RESOLUTION_ORDER.each do |source|
          location = location_for_source(type, name, source)
          return location if location&.exists?
        end
        nil
      end

      # Check if resource exists in any source
      def exists?(type, name)
        resolve(type, name)&.exists? || false
      end

      # List all available resources from all sources
      def list_all(type)
        (list_cached(type) + list_bundled(type)).sort.uniq
      end

      # List resources from specific source
      def list(type, source: :all)
        case source
        when :cached then list_cached(type)
        when :bundled then list_bundled(type)
        else list_all(type)
        end
      end

      private

      def location_for_source(type, name, source)
        case source
        when :cached
          path = File.join(cache_directory_for_type(type), "#{name}.yml")
          ResourceLocation.new(type, name, :cached, path)
        when :bundled
          path = File.join(bundled_directory_for_type(type), "#{name}.yml")
          ResourceLocation.new(type, name, :bundled, path)
        end
      end

      def list_cached(type)
        cache.list(type)
      end

      def list_bundled(type)
        dir = bundled_directory_for_type(type)
        return [] unless File.directory?(dir)

        Dir.glob(File.join(dir, "*.yml")).map { |f| File.basename(f, ".yml") }
      end

      def cache_directory_for_type(type)
        case type
        when :theme then cache.paths.themes
        when :styleset then cache.paths.stylesets
        when :color_scheme then cache.paths.color_schemes
        when :font_scheme then cache.paths.font_schemes
        when :document_element then cache.paths.document_elements
        else raise ArgumentError, "Unknown resource type: #{type}"
        end
      end

      def bundled_directory_for_type(type)
        case type
        when :theme then bundled_path("themes")
        when :styleset then bundled_path("stylesets")
        when :color_scheme then bundled_path("color_schemes")
        when :font_scheme then bundled_path("font_schemes")
        when :document_element then bundled_path("resources/document_elements")
        else raise ArgumentError, "Unknown resource type: #{type}"
        end
      end

      def bundled_path(subdir)
        # Use Gem.datadir if available, otherwise fall back to data/ directory
        data_path = (Gem.datadir("uniword") if defined?(Gem) && Gem.respond_to?(:datadir))
        data_path ||= File.expand_path("../../../data", __dir__)
        File.join(data_path, subdir)
      end
    end
  end
end
