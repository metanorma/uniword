# frozen_string_literal: true

module Uniword
  module FindReplace
    # Abstract scope: knows how to enumerate text-bearing nodes in
    # one part of the package and run a matcher over them.
    #
    # Each subclass implements `each_text_node`, yielding
    # `[holder, accessor]` pairs where `holder` is the object whose
    # text we read/write and `accessor` is a `TextAccessor` value
    # object with `value` and `value=` methods.
    #
    # Open/closed: a new scope = a new subclass + registration in
    # `Engine::SCOPE_REGISTRY`. Engine and other scopes are
    # unchanged.
    class Scope
      # @param document [Wordprocessingml::DocumentRoot]
      def initialize(document)
        @document = document
      end

      # @return [Symbol] scope name (e.g. :body, :headers)
      def name
        raise NotImplementedError
      end

      # Yield `[holder, accessor]` for every text node this scope
      # covers. Engine applies the matcher to each accessor.
      #
      # @yieldparam holder [Wordprocessingml::Text] the Text element
      #   being read/written (its `content` attribute holds the string)
      # @yieldparam accessor [Scope::TextAccessor]
      # @return [void]
      def each_text_node
        raise NotImplementedError
      end

      protected

      # Yield every Text element inside a run. A run carries its
      # `<w:t>` Text elements on the `text` accessor (declared as a
      # collection; lutaml-model 0.8.32+ returns an Array).
      #
      # @param run [Wordprocessingml::Run, nil]
      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [TextAccessor]
      # @return [void]
      def each_text_in_run(run)
        return unless run

        run.text&.each do |text_element|
          accessor = TextAccessor.new(
            -> { text_element.content },
            ->(value) { text_element.content = value },
          )
          yield text_element, accessor
        end
      end

      # Walk every paragraph in `containers` and yield each run's
      # text elements. Shared by body / headers / footers / footnotes
      # / endnotes / comments scopes. Runs inside tracked insertions
      # are live content and included; runs inside deletions are
      # deleted content and left untouched.
      #
      # @param containers [Enumerable<#paragraphs>]
      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [TextAccessor]
      # @return [void]
      def each_text_in_containers(containers)
        ParagraphWalker.each_paragraph(containers) do |paragraph|
          runs = paragraph.runs +
            paragraph.insertions.flat_map(&:runs)
          runs.each do |run|
            each_text_in_run(run) { |*a| yield(*a) }
          end
        end
      end

      # Small value object with a `value` reader and `value=`
      # writer, backed by lambdas. Avoids `instance_variable_set` /
      # `send`; lets callers wire read/write however they like.
      class TextAccessor
        def initialize(reader, writer)
          @reader = reader
          @writer = writer
        end

        def value
          @reader.call
        end

        def value=(new_value)
          @writer.call(new_value)
        end
      end
    end
  end
end
