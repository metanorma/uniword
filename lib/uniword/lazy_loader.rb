# frozen_string_literal: true

module Uniword
  # Module for lazy loading attributes to reduce memory footprint.
  #
  # Lazy loading delays the loading of data until it is actually needed,
  # which helps reduce memory usage for large documents.
  #
  # All cached values are stored in a single Hash (`@_lazy_cache`)
  # accessed via direct ivar reference inside the generated methods.
  #
  # @example Using lazy attributes
  #   class Document
  #     extend LazyLoader
  #
  #     lazy_attr :paragraphs do
  #       parse_paragraphs_from_xml
  #     end
  #   end
  module LazyLoader
    def lazy_attr(name, &loader)
      raise ArgumentError, "Block required for lazy_attr" unless loader

      cache_key = name

      define_method(name) do
        @_lazy_cache ||= {}
        return @_lazy_cache[cache_key] if @_lazy_cache.key?(cache_key)

        @_lazy_cache[cache_key] = instance_exec(&loader)
      end

      define_method("#{name}_loaded?") do
        @_lazy_cache ||= {}
        @_lazy_cache.key?(cache_key)
      end

      define_method("clear_#{name}") do
        @_lazy_cache ||= {}
        @_lazy_cache.delete(cache_key)
      end
    end

    def lazy_collection(name, &loader)
      raise ArgumentError, "Block required for lazy_collection" unless loader

      cache_key = name
      normalizer = method(:normalize_collection)

      define_method(name) do
        @_lazy_cache ||= {}
        return @_lazy_cache[cache_key] if @_lazy_cache.key?(cache_key)

        collection = normalizer.call(instance_exec(&loader))
        @_lazy_cache[cache_key] = collection
        collection
      end

      define_method("#{name}_loaded?") do
        @_lazy_cache ||= {}
        @_lazy_cache.key?(cache_key)
      end

      define_method("clear_#{name}") do
        @_lazy_cache ||= {}
        @_lazy_cache.delete(cache_key)
      end

      define_method("#{name}_count") do
        @_lazy_cache ||= {}
        unless @_lazy_cache.key?(cache_key)
          @_lazy_cache[cache_key] = normalizer.call(instance_exec(&loader))
        end
        @_lazy_cache[cache_key].size
      end
    end

    def normalize_collection(value)
      value = [] if value.nil?
      value = Array(value) unless value.is_a?(Array)
      value
    end
    private :normalize_collection
  end
end
