# frozen_string_literal: true

module Uniword
  module Docx
    # Keyed collection of Docx::Part objects.
    #
    # Backs +chart_parts+ (keyed by relationship id) and +embeddings+
    # (keyed by relationship target). Keeps the legacy Hash-like
    # access patterns working: assignment accepts Part objects, the
    # former raw hashes ({ xml:, target: }) and raw content Strings,
    # normalizing them into Part objects.
    #
    # @example
    #   parts = PartCollection.new(:r_id)
    #   parts["rIdChart1"] = { xml: "...", target: "charts/chart1.xml" }
    #   parts.values.first[:target] # => "charts/chart1.xml"
    class PartCollection
      include Enumerable

      # @param key_attribute [Symbol] part attribute serving as the
      #   collection key (:r_id for charts, :target for embeddings)
      # @param part_class [Class] Part subclass used to wrap raw values
      def initialize(key_attribute, part_class)
        @key_attribute = key_attribute
        @part_class = part_class
        @parts = {}
      end

      # @param key [String] collection key (rId or target)
      # @return [Part, nil]
      def [](key)
        @parts[key]
      end

      # Store a part, normalizing raw hashes and raw content.
      #
      # @param key [String] collection key
      # @param value [Part, Hash, String]
      def []=(key, value)
        @parts[key] = wrap(key, value)
      end

      # Iterate over [key, Part] pairs.
      def each(&block)
        @parts.each(&block)
      end

      # Iterate over collection keys.
      def each_key(&block)
        @parts.each_key(&block)
      end

      # Iterate over stored parts.
      def each_value(&block)
        @parts.each_value(&block)
      end

      # @return [Array<Part>]
      def values
        @parts.values
      end

      # @return [Array<String>]
      def keys
        @parts.keys
      end

      # @return [Integer]
      def size
        @parts.size
      end

      # @return [Boolean]
      def empty?
        @parts.empty?
      end

      # @return [Boolean]
      def key?(key)
        @parts.key?(key)
      end

      # Hash-style alias for key? (RSpec's have_key matcher, legacy
      # callers).
      alias has_key? key?

      # @return [Part, nil] the removed part
      def delete(key)
        @parts.delete(key)
      end

      # Replace the whole collection from a Hash (or another
      # PartCollection); nil clears it.
      #
      # @param value [Hash, PartCollection, nil]
      # @return [void]
      def replace_all(value)
        @parts.clear
        return if value.nil?

        value.each { |key, part| self[key] = part }
      end

      private

      def wrap(key, value)
        case value
        when Part
          value
        when Hash
          @part_class.from_hash(value).tap { |part| assign_key(part, key) }
        else
          @part_class.new(content: value).tap { |part| assign_key(part, key) }
        end
      end

      def assign_key(part, key)
        case @key_attribute
        when :r_id then part.r_id ||= key.to_s
        when :target then part.target ||= key.to_s
        end
      end
    end
  end
end
