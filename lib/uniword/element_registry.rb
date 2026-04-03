# frozen_string_literal: true

module Uniword
  # Registry for all element classes
  # Responsibility: Maintain a registry of element classes and provide factory methods
  #
  # This class follows the Registry pattern to enable:
  # - Automatic registration of element classes via Element.inherited
  # - Runtime element discovery
  # - Factory method for creating elements by tag/type
  class ElementRegistry
    class << self
      # Register an element class
      #
      # @param element_class [Class] The element class to register
      # @return [void]
      def register(element_class)
        return if element_class.respond_to?(:abstract?) && element_class.abstract?

        key = element_class_key(element_class)
        return if key.nil? # Skip anonymous classes

        registry[key] = element_class
      end

      # Create an element instance by tag name
      #
      # @param tag [String, Symbol] The element tag/type name
      # @param attributes [Hash] Attributes to initialize the element with
      # @return [Element, nil] The created element instance or nil if not found
      def create(tag, attributes = {})
        element_class = find(tag)
        return nil unless element_class

        element_class.new(attributes)
      end

      # Find an element class by tag name
      #
      # @param tag [String, Symbol] The element tag/type name
      # @return [Class, nil] The element class or nil if not found
      def find(tag)
        registry[normalize_key(tag)]
      end

      # Get all registered element classes
      #
      # @return [Array<Class>] Array of registered element classes
      def all
        registry.values
      end

      # Get all registered tag names
      #
      # @return [Array<String>] Array of registered tag names
      def tags
        registry.keys
      end

      # Check if a tag is registered
      #
      # @param tag [String, Symbol] The element tag/type name
      # @return [Boolean] true if registered, false otherwise
      def registered?(tag)
        registry.key?(normalize_key(tag))
      end

      # Clear the registry (primarily for testing)
      #
      # @return [void]
      def clear
        registry.clear
      end

      # Get the number of registered elements
      #
      # @return [Integer] Number of registered elements
      def count
        registry.size
      end

      private

      # Get the registry hash
      #
      # @return [Hash<String, Class>] The registry hash
      def registry
        @registry ||= {}
      end

      # Generate a registry key from an element class
      #
      # @param element_class [Class] The element class
      # @return [String, nil] The registry key or nil for anonymous classes
      def element_class_key(element_class)
        class_name = element_class.name
        return nil if class_name.nil? # Anonymous class

        normalize_key(class_name.split('::').last)
      end

      # Normalize a tag name to a registry key
      #
      # @param tag [String, Symbol] The tag name
      # @return [String] The normalized key
      def normalize_key(tag)
        tag.to_s.downcase
      end
    end
  end
end
