# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Paragraph - block-level text element
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:p>
    class Paragraph < Lutaml::Model::Serializable
      attribute :properties, ParagraphProperties
      attribute :runs, Run, collection: true, initialize_empty: true
      attribute :hyperlinks, Hyperlink, collection: true, initialize_empty: true
      attribute :bookmark_starts, BookmarkStart, collection: true, initialize_empty: true
      attribute :bookmark_ends, BookmarkEnd, collection: true, initialize_empty: true
      attribute :field_chars, FieldChar, collection: true, initialize_empty: true
      attribute :instr_text, InstrText, collection: true, initialize_empty: true
      attribute :comment_range_starts, CommentRangeStart, collection: true, initialize_empty: true
      attribute :comment_range_ends, CommentRangeEnd, collection: true, initialize_empty: true
      attribute :comment_references, CommentReference, collection: true, initialize_empty: true
      attribute :alternate_content, AlternateContent, default: nil
      attribute :sdts, StructuredDocumentTag, collection: true, initialize_empty: true
      attribute :o_math_paras, Uniword::Math::OMathPara, collection: true, initialize_empty: true
      attribute :proof_errors, ProofErr, collection: true, initialize_empty: true
      attribute :simple_fields, SimpleField, collection: true, initialize_empty: true

      # Pattern 0: Revision tracking attributes (rsid)
      attribute :rsid_r, :string          # Revision ID for paragraph creation
      attribute :rsid_r_default, :string  # Default revision ID
      attribute :rsid_p, :string          # Revision ID for properties
      attribute :rsid_r_pr, :string       # Revision ID for run properties
      attribute :rsid_del, :string        # Revision ID for deletion
      # Pattern 0: W14 namespace typed attributes
      attribute :para_id, W14ParaId          # Paragraph ID (w14:paraId)
      attribute :text_id, W14TextId          # Text ID (w14:textId)

      # Non-serialized runtime reference to parent document for style inheritance
      # This allows runs to access styles_configuration for style property resolution
      attr_accessor :parent_document

      xml do
        element "p"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Revision tracking attributes
        map_attribute "rsidR", to: :rsid_r, render_nil: false
        map_attribute "rsidRDefault", to: :rsid_r_default, render_nil: false
        map_attribute "rsidP", to: :rsid_p, render_nil: false
        map_attribute "rsidRPr", to: :rsid_r_pr, render_nil: false
        map_attribute "rsidDel", to: :rsid_del, render_nil: false
        # W14 namespace typed attributes - namespace declared on the type class
        map_attribute "paraId", to: :para_id, render_nil: false
        map_attribute "textId", to: :text_id, render_nil: false

        map_element "pPr", to: :properties, render_nil: false
        map_element "r", to: :runs, render_nil: false
        map_element "hyperlink", to: :hyperlinks, render_nil: false
        map_element "bookmarkStart", to: :bookmark_starts, render_nil: false
        map_element "bookmarkEnd", to: :bookmark_ends, render_nil: false
        map_element "fldChar", to: :field_chars, render_nil: false
        map_element "instrText", to: :instr_text, render_nil: false
        map_element "commentRangeStart", to: :comment_range_starts, render_nil: false
        map_element "commentRangeEnd", to: :comment_range_ends, render_nil: false
        map_element "commentReference", to: :comment_references, render_nil: false
        map_element "AlternateContent", to: :alternate_content, render_nil: false
        map_element "sdt", to: :sdts, render_nil: false
        # oMathPara from MathML namespace - the target class declares its namespace
        map_element "oMathPara", to: :o_math_paras,
                                 render_nil: false
        # Proofing errors
        map_element "proofErr", to: :proof_errors, render_nil: false
        map_element "fldSimple", to: :simple_fields, render_nil: false
      end

      # Set paragraph text (replaces all runs with a single run)
      #
      # @param value [String] Text value
      def text=(value)
        runs.clear
        return if value.nil? || value.to_s.empty?

        runs << Run.new(text: value.to_s)
      end

      # Get paragraph text
      #
      # @return [String] Combined text from all runs
      def text
        return "" unless runs

        runs.map { |r| run_text(r) }.join
      end

      # Extract text from a run or SDT element
      #
      # @param run_or_sdt [Run, StructuredDocumentTag] Run or SDT element
      # @return [String] Text content
      def run_text(run_or_sdt)
        if run_or_sdt.is_a?(StructuredDocumentTag)
          extract_sdt_text(run_or_sdt)
        else
          run_or_sdt.text.to_s
        end
      end

      # Extract text from SDT content
      #
      # @param sdt [StructuredDocumentTag] SDT element
      # @return [String] Text content
      def extract_sdt_text(sdt)
        return "" unless sdt.content

        sdt.content.runs.map { |r| r.text.to_s }.join
      end

      # Check if paragraph is empty
      #
      # @return [Boolean] true if no runs or all runs empty
      def empty?
        !runs || runs.empty? || runs.all? { |r| run_text(r).empty? }
      end

      # Get paragraph style (convenience accessor)
      #
      # @return [String, nil] Style name
      def style
        properties&.style
      end

      # Get paragraph alignment (convenience accessor)
      #
      # @return [String, nil] Alignment value (center, left, right, etc.)
      def alignment
        properties&.alignment
      end

      # Iterate over text runs (convenience alias)
      #
      # @yield [Run] Each run in the paragraph
      def each_text_run(&)
        runs.each(&)
      end

      # Remove all content from this paragraph
      def remove!
        runs.clear
      end

      # Numbering ID
      #
      # @return [Integer, nil] Numbering ID
      def num_id
        properties&.num_id
      end

      # Numbering level
      #
      # @return [Integer, nil] Numbering level (0-based)
      def ilvl
        properties&.ilvl
      end

      # Get numbering properties
      #
      # @return [Hash, nil] Hash with :num_id and :level, or nil
      def numbering
        return nil unless properties&.num_id

        { num_id: properties.num_id, level: properties.ilvl }
      end

      # Check if paragraph has numbering
      #
      # @return [Boolean] true if paragraph has numbering
      def numbered?
        properties&.num_id ? true : false
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_paragraph(self)
      end

      # Custom inspect for readable output
      #
      # @return [String] Human-readable representation
      def inspect
        text_preview = text.to_s
        text_preview = "#{text_preview[0, 47]}..." if text_preview.length > 50
        "#<#{self.class} runs=#{runs&.size || 0} text=\"#{text_preview}\">"
      end
    end
  end
end
