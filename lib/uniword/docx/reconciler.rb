# frozen_string_literal: true

require "set"

module Uniword
  module Docx
    # Reconciles DOCX-level invariants before serialization.
    #
    # Ensures that the document's model state is internally consistent so that
    # the serialized output is always a valid DOCX file. Called from
    # Docx::Package#to_zip_content before the serialization phase.
    #
    # This is not an extension point -- it enforces built-in invariants.
    # For customizable validation, use Uniword::Validation::Rules instead.
    # For user-defined requirements, use Docx::Requirement (future).
    class Reconciler
      def initialize(package)
        @package = package
      end

      def reconcile
        reconcile_footnotes
        reconcile_endnotes
      end

      private

      attr_reader :package

      # -- Footnotes --

      def reconcile_footnotes
        has_fn_pr = package.settings&.footnote_pr
        has_footnotes = package.footnotes

        if has_fn_pr && !has_footnotes
          package.footnotes = minimal_footnotes
        elsif has_footnotes && !has_fn_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.footnote_pr = Wordprocessingml::FootnotePr.new
        end

        ensure_separators(package.footnotes, :footnote) if package.footnotes
      end

      # -- Endnotes --

      def reconcile_endnotes
        has_en_pr = package.settings&.endnote_pr
        has_endnotes = package.endnotes

        if has_en_pr && !has_endnotes
          package.endnotes = minimal_endnotes
        elsif has_endnotes && !has_en_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.endnote_pr = Wordprocessingml::EndnotePr.new
        end

        ensure_separators(package.endnotes, :endnote) if package.endnotes
      end

      # -- Builders --

      def minimal_footnotes
        Wordprocessingml::Footnotes.new(
          footnote_entries: [separator_entry(:footnote), continuation_entry(:footnote)]
        )
      end

      def minimal_endnotes
        Wordprocessingml::Endnotes.new(
          endnote_entries: [separator_entry(:endnote), continuation_entry(:endnote)]
        )
      end

      def separator_entry(type)
        entry_class(type).new(
          id: "-1", type: "separator",
          paragraphs: [Wordprocessingml::Paragraph.new]
        )
      end

      def continuation_entry(type)
        entry_class(type).new(
          id: "0", type: "continuationSeparator",
          paragraphs: [Wordprocessingml::Paragraph.new]
        )
      end

      def entry_class(type)
        type == :footnote ? Wordprocessingml::Footnote : Wordprocessingml::Endnote
      end

      def ensure_separators(notes, type)
        entries = notes.public_send(:"#{type}_entries")
        ids = entries.map(&:id).to_set

        entries.unshift(separator_entry(type)) unless ids.include?("-1")
        entries.unshift(continuation_entry(type)) unless ids.include?("0")
      end
    end
  end
end
