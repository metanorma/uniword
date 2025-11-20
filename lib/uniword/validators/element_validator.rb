# frozen_string_literal: true

module Uniword
  module Validators
    # Base validator for element validation
    # Responsibility: Provide validation interface and registry for element validators
    #
    # This class follows the Single Responsibility Principle by separating
    # validation logic from the element classes themselves.
    #
    # @example Using the validator
    #   validator = Uniword::Validators::ElementValidator.for(Paragraph)
    #   validator.valid?(paragraph) # => true or false
    #
    # @example Registering a custom validator
    #   Uniword::Validators::ElementValidator.register(MyElement, MyValidator)
    class ElementValidator
      class << self
        # Get the appropriate validator for an element class
        #
        # @param element_class [Class] The element class to get validator for
        # @return [ElementValidator] An instance of the appropriate validator
        # @raise [ArgumentError] if element_class is not a valid Element class
        def for(element_class)
          unless element_class.is_a?(Class) &&
                 element_class.ancestors.include?(Uniword::Element)
            raise ArgumentError,
                  'element_class must be a subclass of Uniword::Element'
          end

          validator_class = validator_registry[element_class] || self
          validator_class.new
        end

        # Register a validator for a specific element class
        #
        # @param element_class [Class] The element class
        # @param validator_class [Class] The validator class
        # @return [void]
        def register(element_class, validator_class)
          unless validator_class.ancestors.include?(ElementValidator)
            raise ArgumentError,
                  'validator_class must inherit from ElementValidator'
          end

          validator_registry[element_class] = validator_class
        end

        # Get the validator registry
        #
        # @return [Hash] The registry mapping element classes to validators
        def validator_registry
          @validator_registry ||= {}
        end

        # Reset the validator registry (useful for testing)
        #
        # @return [void]
        def reset_registry
          @validator_registry = {}
        end
      end

      # Validate an element
      #
      # @param element [Element] The element to validate
      # @return [Boolean] true if valid, false otherwise
      def valid?(element)
        return false if element.nil?
        return false unless element.is_a?(Uniword::Element)

        # Delegate to element's built-in validation
        element.valid?
      end

      # Get validation errors for an element
      #
      # @param element [Element] The element to validate
      # @return [Array<String>] Array of error messages
      def errors(element)
        return ['Element is nil'] if element.nil?
        return ['Element must be a Uniword::Element'] unless element.is_a?(Uniword::Element)
        return [] if valid?(element)

        ['Element validation failed']
      end
    end
  end
end
