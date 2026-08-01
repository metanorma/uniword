# frozen_string_literal: true

module Uniword
  module Caption
    # Builds a `REF` fldSimple that references a bookmark, producing
    # display text like "Figure 3" or "Table 2" when Word renders it.
    #
    # For Word to refresh these fields on open, set
    # `Settings#update_fields` (the `w:updateFields` element) to
    # `UpdateFields.new` before saving.
    class CrossReference
      # @param bookmark_name [String] target bookmark name
      def initialize(bookmark_name)
        @bookmark_name = bookmark_name
      end

      # @return [Wordprocessingml::SimpleField]
      def build
        Wordprocessingml::SimpleField.new(
          instr: instruction,
          runs: [placeholder_run],
        )
      end

      private

      # The `\h` switch makes the reference a hyperlink (clickable).
      def instruction
        " REF #{@bookmark_name} \\h "
      end

      def placeholder_run
        Wordprocessingml::Run.new(text: [placeholder_text])
      end

      # Word replaces this with the bookmark's display text on
      # field update. uniword writes the bookmark name as a
      # placeholder so the field is never empty before refresh.
      def placeholder_text
        Wordprocessingml::Text.new(content: @bookmark_name)
      end
    end
  end
end
