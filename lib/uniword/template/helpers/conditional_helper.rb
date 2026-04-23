# frozen_string_literal: true

module Uniword
  module Template
    module Helpers
      # Helper for processing conditional markers in templates.
      #
      # Handles {{@if condition}} ... {{@end}} blocks by:
      # 1. Evaluating condition
      # 2. Removing content if false
      # 3. Keeping content if true
      #
      # Responsibility: Conditional processing only
      # Single Responsibility Principle: Does NOT parse or validate
      #
      # @example Process conditional
      #   helper = ConditionalHelper.new(context)
      #   helper.process(start_marker, end_marker, document)
      class ConditionalHelper
        # Initialize helper with context
        #
        # @param context [TemplateContext] Rendering context
        def initialize(context)
          @context = context
        end

        # Process conditional markers
        #
        # @param start_marker [TemplateMarker] Conditional start marker
        # @param end_marker [TemplateMarker] Conditional end marker
        # @param document [Document] Document to modify
        # @return [void]
        def process(start_marker, end_marker, document)
          # Evaluate condition
          resolver = @context.create_resolver
          condition_result = resolver.evaluate(start_marker.condition)

          # If condition is false, remove elements between markers
          return if condition_result

          remove_conditional_content(start_marker, end_marker, document)
        end

        private

        # Remove content between conditional markers
        #
        # @param start_marker [TemplateMarker] Start marker
        # @param end_marker [TemplateMarker] End marker
        # @param document [Document] Document
        # @return [void]
        def remove_conditional_content(start_marker, end_marker, document)
          # Find elements between markers
          elements_to_remove = extract_conditional_elements(start_marker,
                                                            end_marker, document)

          # Remove each element from document
          elements_to_remove.each do |element|
            remove_element(element, document)
          end
        end

        # Extract elements between markers
        #
        # @param start_marker [TemplateMarker] Start marker
        # @param end_marker [TemplateMarker] End marker
        # @param document [Document] Document
        # @return [Array<Element>] Elements to remove
        def extract_conditional_elements(start_marker, end_marker, document)
          elements = []
          in_block = false

          document.paragraphs.each do |para|
            # Check if this is the start marker's element
            if para == start_marker.element
              in_block = true
              elements << para # Include start marker element
              next
            end

            # Collect elements in block
            next unless in_block

            elements << para

            # Check if this is the end marker's element
            break if para == end_marker.element
          end

          elements
        end

        # Remove element from document
        #
        # @param element [Element] Element to remove
        # @param document [Document] Document
        # @return [void]
        def remove_element(element, document)
          # Remove from paragraphs
          document.body.paragraphs.delete(element) if document.body.respond_to?(:paragraphs)

          # Clear document cache
          document.clear_element_cache if document.respond_to?(:clear_element_cache)
        end
      end
    end
  end
end
