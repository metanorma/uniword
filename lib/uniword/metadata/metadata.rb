# frozen_string_literal: true

module Uniword
  module Metadata
    # Represents document metadata.
    #
    # Responsibility: Store and provide access to document metadata.
    # Single Responsibility: Only represents metadata values.
    #
    # A metadata object contains:
    # - Core properties (title, author, subject, keywords, etc.)
    # - Extended properties (company, category, manager, etc.)
    # - Statistical metadata (word_count, page_count, etc.)
    # - Content metadata (headings, first_paragraph, etc.)
    #
    # Metadata is a value object - it represents data, not behavior.
    # Extraction, validation, and updating logic are in separate classes.
    #
    # @example Create metadata
    #   metadata = Metadata.new(
    #     title: "Document Title",
    #     author: "John Doe",
    #     word_count: 1500
    #   )
    #
    # @example Access properties
    #   puts metadata[:title]
    #   puts metadata.title
    #   metadata[:keywords] = ["ISO", "Standard"]
    class Metadata
      # @return [Hash] All metadata properties
      attr_reader :properties

      # Initialize new Metadata instance.
      #
      # @param properties [Hash] Initial metadata properties
      #
      # @example Create with properties
      #   metadata = Metadata.new(
      #     title: "My Document",
      #     author: "Jane Doe",
      #     word_count: 2000
      #   )
      def initialize(properties = {})
        @properties = properties.transform_keys(&:to_sym)
      end

      # Get a metadata value by key.
      #
      # @param key [Symbol, String] Property key
      # @return [Object, nil] Property value or nil
      #
      # @example Get property
      #   title = metadata[:title]
      def [](key)
        @properties[key.to_sym]
      end

      # Set a metadata value by key.
      #
      # @param key [Symbol, String] Property key
      # @param value [Object] Property value
      #
      # @example Set property
      #   metadata[:title] = "New Title"
      def []=(key, value)
        @properties[key.to_sym] = value
      end

      # Get a metadata value with default.
      #
      # @param key [Symbol, String] Property key
      # @param default [Object] Default value if key not found
      # @return [Object] Property value or default
      #
      # @example Get with default
      #   author = metadata.get(:author, "Unknown")
      def get(key, default = nil)
        @properties.fetch(key.to_sym, default)
      end

      # Check if metadata has a property.
      #
      # @param key [Symbol, String] Property key
      # @return [Boolean] true if property exists
      #
      # @example Check property
      #   metadata.has_key?(:title) # => true
      def has_key?(key)
        @properties.key?(key.to_sym)
      end

      # Get all property keys.
      #
      # @return [Array<Symbol>] All property keys
      #
      # @example Get keys
      #   metadata.keys # => [:title, :author, :word_count]
      def keys
        @properties.keys
      end

      # Get all property values.
      #
      # @return [Array<Object>] All property values
      #
      # @example Get values
      #   metadata.values # => ["Title", "Author", 1500]
      def values
        @properties.values
      end

      # Merge with another metadata or hash.
      #
      # @param other [Metadata, Hash] Other metadata to merge
      # @return [Metadata] New merged metadata instance
      #
      # @example Merge metadata
      #   merged = metadata.merge(other_metadata)
      def merge(other)
        other_props = other.is_a?(Metadata) ? other.properties : other
        self.class.new(@properties.merge(other_props))
      end

      # Merge with another metadata or hash in place.
      #
      # @param other [Metadata, Hash] Other metadata to merge
      # @return [self]
      #
      # @example Merge in place
      #   metadata.merge!(other_metadata)
      def merge!(other)
        other_props = other.is_a?(Metadata) ? other.properties : other
        @properties.merge!(other_props.transform_keys(&:to_sym))
        self
      end

      # Select properties matching a condition.
      #
      # @yield [key, value] Block to test each property
      # @return [Hash] Selected properties
      #
      # @example Select core properties
      #   core = metadata.select { |k, v| CORE_KEYS.include?(k) }
      def select(&block)
        @properties.select(&block)
      end

      # Reject properties matching a condition.
      #
      # @yield [key, value] Block to test each property
      # @return [Hash] Rejected properties
      #
      # @example Reject nil values
      #   without_nils = metadata.reject { |k, v| v.nil? }
      def reject(&block)
        @properties.reject(&block)
      end

      # Convert to hash.
      #
      # @param include_nil [Boolean] Include nil values
      # @return [Hash] Hash representation
      #
      # @example Convert to hash
      #   hash = metadata.to_h
      #   hash = metadata.to_h(include_nil: false)
      def to_h(include_nil: true)
        if include_nil
          @properties.dup
        else
          @properties.reject { |_k, v| v.nil? }
        end
      end

      # Convert to JSON-compatible hash.
      #
      # @return [Hash] JSON-compatible hash
      #
      # @example Convert to JSON
      #   json_hash = metadata.to_json_hash
      def to_json_hash
        @properties.each_with_object({}) do |(key, value), result|
          result[key.to_s] = case value
                             when Time, DateTime
                               value.iso8601
                             when Date
                               value.to_s
                             else
                               value
                             end
        end
      end

      # Convert to YAML-compatible hash.
      #
      # @return [Hash] YAML-compatible hash
      #
      # @example Convert to YAML
      #   yaml_hash = metadata.to_yaml_hash
      def to_yaml_hash
        @properties.transform_keys(&:to_s)
      end

      # Check if metadata is empty.
      #
      # @return [Boolean] true if no properties
      #
      # @example Check if empty
      #   metadata.empty? # => false
      def empty?
        @properties.empty?
      end

      # Count of properties.
      #
      # @return [Integer] Number of properties
      #
      # @example Count properties
      #   metadata.size # => 5
      def size
        @properties.size
      end

      # Define method_missing for property access.
      #
      # Allows accessing properties as methods:
      # - metadata.title (getter)
      # - metadata.title = "New" (setter)
      #
      # @param method [Symbol] Method name
      # @param args [Array] Method arguments
      # @return [Object] Property value or result
      def method_missing(method, *args)
        method_str = method.to_s
        if method_str.end_with?('=')
          # Setter: metadata.title = "New"
          key = method_str.chomp('=').to_sym
          self[key] = args.first
        elsif args.empty? && @properties.key?(method.to_sym)
          # Getter: metadata.title
          self[method]
        else
          super
        end
      end

      # Define respond_to_missing? for method_missing.
      #
      # @param method [Symbol] Method name
      # @param include_private [Boolean] Include private methods
      # @return [Boolean] true if method exists
      def respond_to_missing?(method, include_private = false)
        method_str = method.to_s
        if method_str.end_with?('=')
          true
        else
          @properties.key?(method.to_sym) || super
        end
      end

      # Equality comparison.
      #
      # @param other [Metadata] Other metadata
      # @return [Boolean] true if properties are equal
      #
      # @example Compare metadata
      #   metadata1 == metadata2
      def ==(other)
        return false unless other.is_a?(Metadata)
        @properties == other.properties
      end

      # Duplicate the metadata.
      #
      # @return [Metadata] Deep copy of metadata
      #
      # @example Duplicate metadata
      #   copy = metadata.dup
      def dup
        self.class.new(@properties.dup)
      end

      # Deep clone the metadata.
      #
      # @return [Metadata] Deep clone of metadata
      #
      # @example Clone metadata
      #   clone = metadata.clone
      def clone
        self.class.new(deep_clone(@properties))
      end

      # String representation for display.
      #
      # @return [String] String representation
      #
      # @example Display metadata
      #   puts metadata.to_s
      def to_s
        "#<Metadata #{@properties.size} properties>"
      end

      # Detailed inspection for debugging.
      #
      # @return [String] Detailed representation
      def inspect
        props_str = @properties.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
        "#<Uniword::Metadata::Metadata #{props_str}>"
      end

      private

      # Deep clone a value.
      #
      # @param value [Object] Value to clone
      # @return [Object] Cloned value
      def deep_clone(value)
        case value
        when Hash
          value.each_with_object({}) do |(k, v), result|
            result[k] = deep_clone(v)
          end
        when Array
          value.map { |item| deep_clone(item) }
        else
          value.dup rescue value
        end
      end
    end
  end
end