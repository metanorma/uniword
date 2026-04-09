# frozen_string_literal: true

module Uniword
  module Template
    module Helpers
      # Helper for variable substitution in template elements.
      #
      # Replaces element content with resolved variable values.
      # Handles different element types (Paragraph, Run, TableCell).
      #
      # Responsibility: Variable substitution only
      # Single Responsibility Principle: Does NOT resolve or validate
      #
      # @example Replace paragraph content
      #   helper = VariableHelper.new
      #   helper.replace(paragraph, "New Content")
      class VariableHelper
        # Replace element content with value
        #
        # @param element [Element] Element to modify
        # @param value [Object] Value to insert
        # @return [void]
        def replace(element, value)
          # Convert value to string
          text = value.to_s

          case element
          when Uniword::Wordprocessingml::Paragraph
            replace_paragraph(element, text)
          when Uniword::Wordprocessingml::Run
            replace_run(element, text)
          when Uniword::Wordprocessingml::TableCell
            replace_cell(element, text)
          else
            # Try to treat as paragraph-like
            replace_paragraph(element, text) if element.respond_to?(:runs)
          end
        end

        private

        # Replace paragraph content
        #
        # @param paragraph [Paragraph] Paragraph to modify
        # @param text [String] New text content
        # @return [void]
        def replace_paragraph(paragraph, text)
          # Clear existing runs
          paragraph.runs.clear

          # Add new text
          run = Uniword::Wordprocessingml::Run.new(text: text)
          paragraph.runs << run
        end

        # Replace run content
        #
        # @param run [Run] Run to modify
        # @param text [String] New text content
        # @return [void]
        def replace_run(run, text)
          run.text = text
        end

        # Replace cell content
        #
        # @param cell [TableCell] Cell to modify
        # @param text [String] New text content
        # @return [void]
        def replace_cell(cell, text)
          # Replace first paragraph's content
          if cell.paragraphs.any?
            replace_paragraph(cell.paragraphs.first, text)
          else
            # Create new paragraph with text
            para = Uniword::Wordprocessingml::Paragraph.new
            run = Uniword::Wordprocessingml::Run.new(text: text)
            para.runs << run
            cell.paragraphs << para
          end
        end
      end
    end
  end
end
