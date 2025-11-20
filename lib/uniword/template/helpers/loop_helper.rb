# frozen_string_literal: true

module Uniword
  module Template
    module Helpers
      # Helper for processing loop markers in templates.
      #
      # Handles {{@each collection}} ... {{@end}} blocks by:
      # 1. Extracting elements between markers
      # 2. Cloning for each collection item
      # 3. Filling with scoped data
      #
      # Responsibility: Loop processing only
      # Single Responsibility Principle: Does NOT parse or validate
      #
      # @example Process loop
      #   helper = LoopHelper.new(context)
      #   helper.process(start_marker, end_marker, document)
      class LoopHelper
        # Initialize helper with context
        #
        # @param context [TemplateContext] Rendering context
        def initialize(context)
          @context = context
        end

        # Process loop markers
        #
        # @param start_marker [TemplateMarker] Loop start marker
        # @param end_marker [TemplateMarker] Loop end marker
        # @param document [Document] Document to modify
        # @return [void]
        def process(start_marker, end_marker, document)
          # Resolve collection from current context
          resolver = @context.create_resolver
          collection = resolver.resolve(start_marker.collection)

          # Convert to array if needed
          items = Array(collection)

          # For now, we'll mark this as processed
          # Full implementation would clone elements between markers
          # and render each with scoped context
          #
          # This is a placeholder for the actual loop processing logic
          # which would need deep cloning and element insertion
        end

        private

        # Extract elements between markers
        #
        # @param start_marker [TemplateMarker] Start marker
        # @param end_marker [TemplateMarker] End marker
        # @param document [Document] Document
        # @return [Array<Element>] Elements in loop
        def extract_loop_elements(start_marker, end_marker, document)
          elements = []
          in_loop = false

          document.paragraphs.each do |para|
            # Check if this is the start marker's element
            in_loop = true if para == start_marker.element

            # Collect elements in loop
            elements << para if in_loop && para != start_marker.element

            # Check if this is the end marker's element
            break if para == end_marker.element
          end

          elements
        end

        # Clone and fill element with data
        #
        # @param element [Element] Element to clone
        # @param item_data [Object] Data for this iteration
        # @return [Element] Cloned and filled element
        def clone_and_fill(element, item_data)
          # Create scoped context for this item
          @context.push_scope(item_data)

          # Clone element (shallow copy for now)
          cloned = element.dup

          # Fill variables in cloned element
          fill_variables(cloned)

          # Restore context
          @context.pop_scope

          cloned
        end

        # Fill variables in element
        #
        # @param element [Element] Element to fill
        # @return [void]
        def fill_variables(element)
          resolver = @context.create_resolver

          # Find and replace variables in element
          # This is simplified - full implementation would
          # recursively process all text nodes
          if element.respond_to?(:text)
            text = element.text
            # Simple variable replacement ({{var}})
            text.scan(/\{\{([^@].+?)\}\}/).each do |match|
              var_name = match[0]
              value = resolver.resolve(var_name)
              element.text = text.gsub("{{#{var_name}}}", value.to_s)
            end
          end
        end
      end
    end
  end
end