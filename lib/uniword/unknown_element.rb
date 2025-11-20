# frozen_string_literal: true

module Uniword
  # Represents an unknown or unsupported OOXML element.
  #
  # Responsibility: Preserve raw OOXML for elements not yet supported in schema.
  # Single Responsibility: Only stores and returns raw XML unchanged.
  #
  # This class is the foundation for perfect round-trip fidelity. When the
  # deserializer encounters an element not in the schema, it creates an
  # UnknownElement to preserve the raw XML. During serialization, the raw
  # XML is output unchanged, ensuring no data loss.
  #
  # This enables incremental schema expansion: we can add proper support
  # for elements gradually while maintaining perfect round-trip from day one.
  #
  # @example Preserve a chart element
  #   # During deserialization
  #   unknown = UnknownElement.new(
  #     tag_name: 'chart',
  #     raw_xml: '<c:chart xmlns:c="...">...</c:chart>',
  #     namespace: 'http://schemas.openxmlformats.org/drawingml/2006/chart'
  #   )
  #
  #   # During serialization
  #   unknown.to_xml  # Returns exact original XML
  #
  # @example With warning integration
  #   collector = WarningCollector.new
  #   unknown = UnknownElement.new(
  #     tag_name: 'smartArt',
  #     raw_xml: '<dgm:relIds xmlns:dgm="...">...</dgm:relIds>',
  #     namespace: 'http://schemas.openxmlformats.org/drawingml/2006/diagram',
  #     warning_collector: collector
  #   )
  class UnknownElement
    # @return [String] The XML tag name (e.g., 'chart', 'smartArt')
    attr_reader :tag_name

    # @return [String] The complete raw XML for this element
    attr_reader :raw_xml

    # @return [String, nil] The XML namespace URI
    attr_reader :namespace

    # @return [String, nil] Context where element was found
    attr_reader :context

    # @return [Boolean] Whether this element is critical (affects document structure)
    attr_reader :critical

    # Initialize a new UnknownElement.
    #
    # @param tag_name [String] The XML tag name
    # @param raw_xml [String] The complete raw XML
    # @param namespace [String, nil] The XML namespace URI (optional)
    # @param context [String, nil] Context where found (optional)
    # @param critical [Boolean] Whether element is critical (default: false)
    # @param warning_collector [WarningCollector, nil] Optional warning collector
    #
    # @raise [ArgumentError] if tag_name or raw_xml is nil/empty
    #
    # @example Create unknown element
    #   unknown = UnknownElement.new(
    #     tag_name: 'chart',
    #     raw_xml: '<c:chart>...</c:chart>',
    #     namespace: 'http://schemas.openxmlformats.org/drawingml/2006/chart',
    #     context: 'In paragraph 5'
    #   )
    def initialize(tag_name:, raw_xml:, namespace: nil, context: nil,
                   critical: false, warning_collector: nil)
      validate_parameters(tag_name, raw_xml)

      @tag_name = tag_name
      @raw_xml = raw_xml
      @namespace = namespace
      @context = context
      @critical = critical

      # Record warning if collector provided
      record_warning(warning_collector) if warning_collector
    end

    # Return the raw XML unchanged for serialization.
    #
    # This is the core method that enables perfect round-trip: we simply
    # output the exact XML we received, preserving all data and structure.
    #
    # @return [String] The raw XML exactly as it was parsed
    #
    # @example Serialize unknown element
    #   xml = unknown.to_xml  # Returns original XML unchanged
    def to_xml
      @raw_xml
    end

    # Check if this is a critical element.
    #
    # Critical elements affect document structure and may cause issues
    # if lost (e.g., content controls, section breaks).
    #
    # @return [Boolean] true if element is critical
    def critical?
      @critical
    end

    # Get element type classification.
    #
    # Classifies unknown elements into categories to help users understand
    # the impact of unsupported elements.
    #
    # @return [Symbol] Element category
    #
    # @example Get element type
    #   unknown.element_type  # => :data (for charts, diagrams)
    #                         # => :formatting (for advanced styling)
    #                         # => :structure (for content controls)
    def element_type
      classify_element(@tag_name)
    end

    # Convert to hash representation.
    #
    # @return [Hash] Hash with element information
    def to_h
      {
        tag_name: @tag_name,
        namespace: @namespace,
        context: @context,
        critical: @critical,
        element_type: element_type,
        xml_length: @raw_xml.length
      }.compact
    end

    # String representation for debugging.
    #
    # @return [String] Human-readable description
    def to_s
      type_str = critical? ? ' (CRITICAL)' : ''
      ns_str = @namespace ? " [#{@namespace}]" : ''
      "UnknownElement: #{@tag_name}#{ns_str}#{type_str}"
    end

    # Detailed inspection for debugging.
    #
    # @return [String] Detailed description including XML preview
    def inspect
      xml_preview = @raw_xml.length > 100 ? "#{@raw_xml[0..97]}..." : @raw_xml
      "#<#{self.class} @tag_name=#{@tag_name.inspect} " \
        "@namespace=#{@namespace.inspect} " \
        "@critical=#{@critical} " \
        "@xml_length=#{@raw_xml.length} " \
        "@xml_preview=#{xml_preview.inspect}>"
    end

    private

    # Validate constructor parameters.
    #
    # @param tag_name [Object] The tag name to validate
    # @param raw_xml [Object] The raw XML to validate
    # @raise [ArgumentError] if parameters are invalid
    def validate_parameters(tag_name, raw_xml)
      if tag_name.nil? || tag_name.to_s.strip.empty?
        raise ArgumentError, 'tag_name cannot be nil or empty'
      end

      if raw_xml.nil? || raw_xml.to_s.strip.empty?
        raise ArgumentError, 'raw_xml cannot be nil or empty'
      end
    end

    # Record warning about unknown element.
    #
    # @param collector [WarningCollector] The warning collector
    def record_warning(collector)
      return unless collector.respond_to?(:record_unsupported)

      collector.record_unsupported(
        @tag_name,
        context: @context || 'Unknown location',
        location: nil
      )
    end

    # Classify element into category.
    #
    # This classification helps users understand the impact of unsupported
    # elements and guides schema expansion priorities.
    #
    # @param tag [String] The element tag name
    # @return [Symbol] Element category
    def classify_element(tag)
      tag_lower = tag.to_s.downcase

      # Data elements: charts, diagrams, equations
      if tag_lower.match?(/chart|diagram|smartart|math|equation/)
        :data
      # Structure elements: content controls, sections
      elsif tag_lower.match?(/sdt|control|sect/)
        :structure
      # Formatting elements: advanced styles, effects
      elsif tag_lower.match?(/style|effect|theme|color/)
        :formatting
      # Metadata elements: document properties, settings
      elsif tag_lower.match?(/property|setting|metadata/)
        :metadata
      else
        :unknown
      end
    end
  end
end