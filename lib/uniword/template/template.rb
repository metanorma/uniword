# frozen_string_literal: true

# All Template classes autoloaded via lib/uniword/template.rb

module Uniword
  module Template
    # Main template class for Word document templates.
    #
    # Represents a Word document with embedded Uniword template syntax
    # in comments. Coordinates parsing and rendering to produce filled
    # documents from data.
    #
    # Workflow:
    # 1. Load template from .docx file
    # 2. Extract markers from comments (via TemplateParser)
    # 3. Render with data (via TemplateRenderer)
    # 4. Save filled document
    #
    # @example Load and render template
    #   template = Template.load('report_template.docx')
    #   data = { title: "Annual Report", sections: [...] }
    #   document = template.render(data)
    #   document.save('filled_report.docx')
    #
    # @attr_reader [Document] document Template document
    # @attr_reader [Array<TemplateMarker>] markers Extracted template markers
    class Template
      attr_reader :document, :markers

      # Load template from .docx file
      #
      # @param template_path [String] Path to template file
      # @return [Template] Loaded template
      def self.load(template_path)
        doc = Uniword::DocumentFactory.from_file(template_path)
        new(doc)
      end

      # Initialize template with document
      #
      # @param document [Document] Template document
      def initialize(document)
        @document = document
        @markers = extract_markers
      end

      # Render template with data
      #
      # Creates a new document by filling the template with provided data.
      # Supports both Hash and custom object data sources.
      #
      # @param data [Hash, Object] Data to fill template
      # @param context [Hash] Additional context variables
      # @return [Document] Rendered document
      #
      # @example Render with hash
      #   doc = template.render(title: "My Document")
      #
      # @example Render with custom object
      #   doc = template.render(my_model_object)
      #
      # @example Render with context
      #   doc = template.render(data, context: { author: "John" })
      def render(data, context: {})
        renderer = TemplateRenderer.new(self, data, context)
        renderer.render
      end

      # Preview template structure
      #
      # Returns information about markers for debugging and validation.
      #
      # @return [Hash] Template structure info
      def preview
        {
          markers: @markers.count,
          variables: variables,
          loops: loops,
          conditionals: conditionals.count,
        }
      end

      # Get all variable markers
      #
      # @return [Array<String>] Variable names
      def variables
        @markers.select(&:variable?).map(&:expression)
      end

      # Get all loop markers
      #
      # @return [Array<Hash>] Loop information
      def loops
        loop_starts = @markers.select(&:loop_start?)
        loop_starts.map do |m|
          { collection: m.collection, position: m.position }
        end
      end

      # Get all conditional markers
      #
      # @return [Array<TemplateMarker>] Conditional markers
      def conditionals
        @markers.select(&:conditional_start?)
      end

      # Check if document is a template
      #
      # @return [Boolean] true if contains markers
      def template?
        @markers.any?
      end

      # Validate template structure
      #
      # @return [Array<String>] Validation errors (empty if valid)
      def validate
        validator = TemplateValidator.new(self)
        validator.validate
      end

      # Check if template is valid
      #
      # @return [Boolean] true if valid
      def valid?
        validate.empty?
      end

      # Inspect template for debugging
      #
      # @return [String] Readable representation
      def inspect
        "#<Uniword::Template markers=#{@markers.count} " \
          "variables=#{variables.count} " \
          "loops=#{loops.count}>"
      end

      private

      # Extract markers from document
      #
      # @return [Array<TemplateMarker>] Extracted markers
      def extract_markers
        parser = TemplateParser.new(@document)
        parser.parse
      end
    end
  end
end
