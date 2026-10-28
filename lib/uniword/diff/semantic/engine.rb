# frozen_string_literal: true

module Uniword
  module Diff
    module Semantic
      # Orchestrates element-level diff between two documents.
      # Currently compares body paragraphs; future comparators
      # (tables, images, styles) plug in via `COMPARATORS`.
      class Engine
        # @param old_doc [Wordprocessingml::DocumentRoot]
        # @param new_doc [Wordprocessingml::DocumentRoot]
        def initialize(old_doc, new_doc)
          @old_doc = old_doc
          @new_doc = new_doc
        end

        # Run every registered comparator and aggregate the changes.
        #
        # @return [Result]
        def diff
          result = Result.new
          ParagraphComparator.each_change(@old_doc.paragraphs,
                                          @new_doc.paragraphs) do |change|
            result.add(change)
          end
          result
        end
      end
    end
  end
end
