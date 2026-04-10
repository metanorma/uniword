# frozen_string_literal: true

require 'json'

module Uniword
  module Resource
    # MODEL for cache version tracking
    # Has state (cache reference) and behavior (check staleness, update)
    #
    # Does NOT extend Lutaml::Model::Serializable.
    class CacheVersion
      attr_reader :cache

      def initialize(cache)
        @cache = cache
      end

      # Get cached Word version
      def cached_version
        return nil unless File.exist?(cache.paths.version_file)

        JSON.parse(File.read(cache.paths.version_file))['word_version']
      rescue JSON::ParserError
        nil
      end

      # Update cached version
      def update(word_version)
        cache.paths.ensure_directories_exist!
        File.write(cache.paths.version_file, JSON.generate(word_version: word_version))
      end

      # Check if cache is stale (Word was updated)
      def stale?(current_word_version)
        cached_version != current_word_version
      end

      # Check if cache exists
      def exists?
        File.exist?(cache.paths.version_file)
      end

      # Delete version file
      def delete
        FileUtils.rm_f(cache.paths.version_file)
      end
    end
  end
end
