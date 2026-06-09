# frozen_string_literal: true

module Uniword
  module Builder
    # Shared run utilities used by both ParagraphBuilder (build-time) and
    # Reconciler::Helpers (reconcile-time).
    #
    # Provides canonical implementations of run classification and merging.
    # Both modules delegate here to ensure identical behavior.
    module RunUtils
      module_function

      # Whether a run contains no renderable content.
      #
      # A run is empty only if it has no text content and no structural
      # elements (breaks, tabs, drawings, field chars, etc.).
      def empty_run?(run)
        return false if run.break
        return false if run.tab
        return false if run.drawings&.any?
        return false if run.pictures&.any?
        return false if run.alternate_content
        return false if run.footnote_reference
        return false if run.endnote_reference
        return false if run.field_char
        return false if run.instr_text
        return false if run.position_tab
        return false if run.del_text
        return false if run.no_break_hyphen
        return false if run.sym
        return false if run.last_rendered_page_break
        return false if run.separator_char
        return false if run.continuation_separator_char

        t = run.text
        return true unless t

        content = t.content if t.class.attributes.key?(:content)
        content = t.value if content.nil? && t.class.attributes.key?(:value)
        !content.is_a?(String) || content.empty?
      end

      # Whether a run contains only text (no structural elements).
      #
      # Runs with drawings, breaks, tabs, field chars, etc. are NOT
      # text-only and should never be merged with other runs.
      def text_only_run?(run)
        return false if run.drawings&.any?
        return false if run.pictures&.any?
        return false if run.alternate_content
        return false if run.footnote_reference
        return false if run.endnote_reference
        return false if run.field_char
        return false if run.instr_text
        return false if run.sym
        return false if run.break
        return false if run.tab
        return false if run.position_tab
        return false if run.no_break_hyphen
        return false if run.del_text

        true
      end

      # Whether two runs have identical formatting (RunProperties).
      def properties_match?(a, b)
        rpr_a = a.properties
        rpr_b = b.properties
        return true if rpr_a.nil? && rpr_b.nil?
        return false if rpr_a.nil? || rpr_b.nil?

        rpr_a.to_xml == rpr_b.to_xml
      end

      # Whether two text-only runs can be merged.
      #
      # Runs can be merged if both are text-only with identical formatting.
      def mergeable?(existing, incoming)
        return false unless text_only_run?(existing) && text_only_run?(incoming)
        return false unless incoming.text&.to_s && !incoming.text.to_s.empty?

        properties_match?(existing, incoming)
      end

      # Merge source run's text into target run.
      #
      # Handles xml:space="preserve" for whitespace-sensitive content.
      def merge_text(target, source)
        if source.text
          existing = target.text&.to_s
          appended = source.text.to_s
          combined = existing + appended
          new_text = Wordprocessingml::Text.new(content: combined)
          if Wordprocessingml::Text.preserve_whitespace?(combined)
            new_text.xml_space = "preserve"
          end
          target.text = new_text
        end
      end
    end
  end
end
