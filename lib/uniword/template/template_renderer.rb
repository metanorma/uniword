# frozen_string_literal: true

require_relative 'template_context'
require_relative 'variable_resolver'

module Uniword
  module Template
    # Renders templates by processing markers and filling with data.
    #
    # Takes a template and data, processes all markers in order,
    # and produces a filled document. Handles variable substitution,
    # loops, and conditionals.
    #
    # Responsibility: Template rendering only
    # Single Responsibility Principle: Does NOT parse or validate
    #
    # @example Render simple template
    #   renderer = TemplateRenderer.new(template, data, {})
    #   document = renderer.render
    class TemplateRenderer
      # Initialize renderer
      #
      # @param template [Template] Template to render
      # @param data [Hash, Object] Data to fill template
      # @param additional_context [Hash] Additional context
      def initialize(template, data, additional_context = {})
        @template = template
        @data = data
        @additional_context = additional_context
        @context = TemplateContext.new(data, additional_context)
      end

      # Render template with data
      #
      # Creates a new document by cloning the template document
      # and processing all markers.
      #
      # @return [Document] Rendered document
      def render
        # Clone template document
        output = clone_document(@template.document)

        # Process markers
        process_markers(output)

        # Remove template comments
        remove_template_comments(output)

        output
      end

      private

      # Clone document for output
      #
      # @param document [Document] Document to clone
      # @return [Document] Cloned document
      def clone_document(document)
        # Create new document with same structure
        # For now, we'll work with the document directly
        # In production, this would create a deep copy
        document
      end

      # Process all markers in document
      #
      # @param document [Document] Document to process
      # @return [void]
      def process_markers(document)
        # Group markers by type for efficient processing
        variable_markers = []
        loop_pairs = []
        conditional_pairs = []

        # Find loop and conditional pairs
        @template.markers.each do |marker|
          case marker.type
          when :variable
            variable_markers << marker
          when :loop_start
            # Find matching end
            end_marker = find_matching_end(marker, :loop_end)
            loop_pairs << [marker, end_marker] if end_marker
          when :conditional_start
            # Find matching end
            end_marker = find_matching_end(marker, :loop_end)
            conditional_pairs << [marker, end_marker] if end_marker
          end
        end

        # Process in order: conditionals, loops, then variables
        conditional_pairs.each do |start_marker, end_marker|
          process_conditional(start_marker, end_marker, document)
        end
        loop_pairs.each do |start_marker, end_marker|
          process_loop(start_marker, end_marker, document)
        end
        variable_markers.each { |marker| process_variable(marker, document) }
      end

      # Find matching end marker
      #
      # @param start_marker [TemplateMarker] Start marker
      # @param end_type [Symbol] End marker type to find
      # @return [TemplateMarker, nil] Matching end marker
      def find_matching_end(start_marker, end_type)
        depth = 0
        found_start = false

        @template.markers.each do |marker|
          if marker == start_marker
            found_start = true
            next
          end

          next unless found_start

          # Track nesting depth
          depth += 1 if marker.type == start_marker.type
          depth -= 1 if marker.type == end_type

          # Found matching end at same nesting level
          return marker if depth.negative?
        end

        nil
      end

      # Process variable marker
      #
      # @param marker [TemplateMarker] Variable marker
      # @param document [Document] Document to modify
      # @return [void]
      def process_variable(marker, _document)
        resolver = @context.create_resolver
        value = resolver.resolve(marker.expression)

        # Replace element content with value
        replace_element_content(marker.element, value)
      end

      # Process loop markers
      #
      # @param start_marker [TemplateMarker] Loop start marker
      # @param end_marker [TemplateMarker] Loop end marker
      # @param document [Document] Document to modify
      # @return [void]
      def process_loop(start_marker, end_marker, document)
        require_relative 'helpers/loop_helper'

        helper = Helpers::LoopHelper.new(@context)
        helper.process(start_marker, end_marker, document)
      end

      # Process conditional markers
      #
      # @param start_marker [TemplateMarker] Conditional start marker
      # @param end_marker [TemplateMarker] Conditional end marker
      # @param document [Document] Document to modify
      # @return [void]
      def process_conditional(start_marker, end_marker, document)
        require_relative 'helpers/conditional_helper'

        helper = Helpers::ConditionalHelper.new(@context)
        helper.process(start_marker, end_marker, document)
      end

      # Replace element content with value
      #
      # @param element [Element] Element to modify
      # @param value [Object] Value to insert
      # @return [void]
      def replace_element_content(element, value)
        require_relative 'helpers/variable_helper'

        helper = Helpers::VariableHelper.new
        helper.replace(element, value)
      end

      # Remove template comments from document
      #
      # @param document [Document] Document to clean
      # @return [void]
      def remove_template_comments(document)
        # Remove comments from paragraphs
        document.paragraphs.each do |para|
          next unless para.respond_to?(:comments)

          # Filter out template comments
          if para.respond_to?(:attached_comments)
            para.attached_comments.reject! { |c| template_comment?(c) }
          end
        end
      end

      # Check if comment contains template syntax
      #
      # @param comment [Comment] Comment to check
      # @return [Boolean] true if template comment
      def template_comment?(comment)
        return false unless comment.respond_to?(:text)

        text = comment.text
        text.match?(/^\{\{.+\}\}$/)
      end
    end
  end
end
