# frozen_string_literal: true

module Uniword
  module Resource
    # MODEL for cache operations
    # Has state (paths, cached resources) and behavior (CRUD)
    #
    # Does NOT extend Lutaml::Model::Serializable because it doesn't need serialization.
    class Cache
      attr_reader :paths

      def initialize(word_impl = nil)
        word_impl ||= Uniword::WordImplementation.detect
        @paths = CachePaths.from_word_implementation(word_impl)
      end

      # Write resource to cache
      def write(type, name, content)
        paths.ensure_directories_exist!
        path = resource_path(type, name)
        File.write(path, content)
        path
      end

      # Read resource from cache
      def read(type, name)
        path = resource_path(type, name)
        File.read(path) if File.exist?(path)
      end

      # Check if resource exists in cache
      def exists?(type, name)
        File.exist?(resource_path(type, name))
      end

      # List all cached resources of a type
      def list(type)
        dir = directory_for_type(type)
        return [] unless File.directory?(dir)

        Dir.glob(File.join(dir, "*.yml")).map { |f| File.basename(f, ".yml") }
      end

      # Count cached resources of a type
      def count(type)
        list(type).size
      end

      # Delete resource from cache
      def delete(type, name)
        path = resource_path(type, name)
        FileUtils.rm_f(path)
      end

      # Clear all cache or specific type
      def clear!(type: :all)
        if type == :all
          FileUtils.rm_rf(paths.base)
        else
          dir = directory_for_type(type)
          FileUtils.rm_rf(dir)
        end
      end

      private

      def directory_for_type(type)
        case type
        when :theme then paths.themes
        when :styleset then paths.stylesets
        when :color_scheme then paths.color_schemes
        when :font_scheme then paths.font_schemes
        else raise ArgumentError, "Unknown resource type: #{type}"
        end
      end

      def resource_path(type, name)
        File.join(directory_for_type(type), "#{name}.yml")
      end
    end
  end
end
