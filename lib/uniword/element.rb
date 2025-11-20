# frozen_string_literal: true

module Uniword
  # Abstract base class for all document elements
  # Responsibility: Define element interface and common behavior
  #
  # This class follows the Visitor pattern to enable extensible operations
  # on the element hierarchy without modifying the element classes themselves.
  #
  # All subclasses are automatically registered via the inherited hook,
  # enabling runtime element discovery and factory patterns.
  #
  # v2.0.0: Added schema-driven .to_xml() method for element-level serialization
  class Element < Lutaml::Model::Serializable
    # All elements have an optional ID for referencing
    attribute :id, :string

    class << self
      # Hook called when a class inherits from Element
      # Automatically registers the subclass for runtime discovery
      #
      # @param subclass [Class] The subclass being defined
      # @return [void]
      def inherited(subclass)
        super
        # Register the subclass if ElementRegistry is available
        # This allows lazy loading - registry can be loaded after Element
        return unless defined?(Uniword::ElementRegistry)

        Uniword::ElementRegistry.register(subclass)
      end

      # Check if this class is abstract (cannot be instantiated directly)
      #
      # @return [Boolean] true if abstract, false otherwise
      def abstract?
        self == Element
      end
    end

    # Visitor pattern support
    # Subclasses must implement this method to enable visitor operations
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    # @raise [NotImplementedError] if not implemented by subclass
    def accept(visitor)
      raise NotImplementedError,
            "#{self.class} must implement accept(visitor) method"
    end

    # Validation method
    # Default implementation returns true
    # Subclasses can override for specific validation logic
    # For complex validation, use Validators module
    #
    # @return [Boolean] true if valid, false otherwise
    def valid?
      # Basic validation: check required attributes
      required_attributes_valid?
    end

    # Serialize element to OOXML XML using schema definition
    #
    # v2.0.0: Schema-driven element serialization.
    # Uses external YAML schema to determine XML structure.
    #
    # @param options [Hash] Serialization options
    # @option options [Boolean] :pretty (false) Pretty print XML
    # @option options [Boolean] :standalone (false) Include XML declaration
    # @return [String] OOXML XML string
    # @raise [ArgumentError] if element has no schema definition
    #
    # @example Serialize paragraph
    #   para = Uniword::Paragraph.new
    #   para.add_text("Hello")
    #   xml = para.to_xml
    #   # => "<w:p><w:r><w:t>Hello</w:t></w:r></w:p>"
    def to_xml(options = {})
      require_relative 'ooxml/schema/element_serializer'

      serializer = Ooxml::Schema::ElementSerializer.new
      serializer.serialize(self, options)
    end

    protected

    # Check if required attributes are valid
    # Can be extended by subclasses
    #
    # @return [Boolean] true if all required attributes are present
    def required_attributes_valid?
      true # Base implementation, override in subclasses if needed
    end
  end
end
