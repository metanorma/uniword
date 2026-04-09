# frozen_string_literal: true

module Uniword
  module Resource
    # Immutable value object for resource location
    # Does NOT extend Lutaml::Model::Serializable - this is a value object
    ResourceLocation = Struct.new(:type, :name, :source, :path) do
      # Check if location is readable
      def exists?
        File.exist?(path)
      end

      # Read content
      def read
        File.read(path) if exists?
      end

      # Factory from path
      def self.from_path(type, path)
        name = File.basename(path, '.*')
        source = determine_source(path)
        new(type, name, source, path)
      end

      def self.determine_source(path)
        case path
        when %r{/\.uniword/} then :cached
        when %r{/data-private/} then :private
        when %r{/data/} then :bundled
        else :unknown
        end
      end
    end
  end
end
