# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Removes styles from a document's style definitions — Word's
    # Styles-pane management as an API.
    #
    # `#remove_unused` deletes styles that no content references,
    # directly (pStyle/rStyle/tblStyle in body, headers, footers, notes,
    # comments) or transitively (basedOn/link/next chains from a used
    # style, numbering level pStyle). Default styles (w:default="1")
    # are never removed.
    #
    # @example Declutter a document
    #   cleanup = StyleCleanup.new(document)
    #   removed = cleanup.remove_unused # => ["ObsoleteStyle", ...]
    class StyleCleanup
      # @param document [DocumentRoot] Document to clean (mutated)
      def initialize(document)
        @document = document
      end

      # Remove one style by id (unless protected).
      #
      # @param style_id [String] Style id (w:styleId)
      # @return [Boolean] true when the style was removed
      def remove?(style_id)
        return false if protected_id?(style_id)

        before = styles.size
        styles.delete_if { |style| style.styleId == style_id }
        styles.size < before
      end

      # Ids of styles no content references.
      #
      # @return [Array<String>] Unreferenced, unprotected style ids
      def unused_ids
        used = used_ids
        styles.filter_map(&:styleId).uniq - used - protected_ids
      end

      # Remove every unreferenced style.
      #
      # @return [Array<String>] Ids of removed styles
      def remove_unused
        ids = unused_ids
        ids.each { |id| remove?(id) }
        ids
      end

      private

      def styles
        @document.styles_configuration.styles
      end

      def protected_ids
        styles.select(&:default).map(&:styleId)
      end

      def protected_id?(style_id)
        protected_ids.include?(style_id)
      end

      # Ids referenced anywhere: content, notes, headers/footers,
      # comments, numbering levels, and style-to-style chains.
      def used_ids
        used = content_style_ids + chain_seed_ids
        expand_chains(used)
      end

      def content_style_ids
        ids = []
        walk_all_paragraphs do |paragraph|
          ids.concat(paragraph_style_ids(paragraph))
          ids.concat(run_style_ids(paragraph))
        end
        ids.concat(table_style_ids)
        ids.concat(numbering_style_ids)
        ids
      end

      # Styles referenced by other styles (basedOn/link/next) — chains
      # are expanded from these too.
      def chain_seed_ids
        styles.flat_map { |style| chain_links(style) }
      end

      def chain_links(style)
        [style.basedOn&.val, style.link&.val, style.nextStyle&.val].compact
      end

      def expand_chains(ids)
        expanded = ids.to_set
        loop do
          additions = chain_additions(expanded)
          break if additions.empty?

          additions.each { |id| expanded << id }
        end
        expanded.to_a
      end

      def chain_additions(expanded)
        styles.select { |style| expanded.include?(style.styleId) }
          .flat_map { |style| chain_links(style) }
          .reject { |id| expanded.include?(id) }
      end

      def paragraph_style_ids(paragraph)
        Array(paragraph.properties&.style).filter_map(&:value)
      end

      def run_style_ids(paragraph)
        paragraph_runs(paragraph)
          .filter_map { |run| run.properties&.style&.value }
      end

      def paragraph_runs(paragraph)
        (paragraph.runs || []) +
          (paragraph.hyperlinks || []).flat_map(&:runs)
      end

      def table_style_ids
        ids = []
        walk_tables(@document.body) do |table|
          ids << table.properties&.style&.val
        end
        ids.compact
      end

      def numbering_style_ids
        numbering_definitions.flat_map do |definition|
          (definition.levels || []).filter_map { |level| level.pStyle&.val }
        end
      end

      def numbering_definitions
        @document.numbering_configuration&.definitions || []
      end

      # Paragraphs in body (incl. table cells), headers/footers,
      # notes, comments.
      def walk_all_paragraphs(&block)
        each_container { |container| walk_paragraphs(container, &block) }
      end

      def walk_paragraphs(container, &block)
        return unless container

        (container.paragraphs || []).each(&block)
        walk_tables(container) { |table| walk_table_rows(table, &block) }
      end

      def walk_table_rows(table, &block)
        (table.rows || []).each do |row|
          (row.cells || []).each { |cell| walk_paragraphs(cell, &block) }
        end
      end

      def walk_tables(container, &block)
        return unless container

        (container.tables || []).each do |table|
          yield table
          walk_table_cells(table, &block)
        end
      end

      def walk_table_cells(table, &block)
        (table.rows || []).each do |row|
          (row.cells || []).each { |cell| walk_tables(cell, &block) }
        end
      end

      def each_container(&block)
        yield @document.body if @document.body
        header_footer_containers.each(&block)
        note_containers.each(&block)
      end

      def header_footer_containers
        (@document.header_footer_parts || []).filter_map do |part|
          part.content if part.content.is_a?(Lutaml::Model::Serializable)
        end
      end

      def note_containers
        [
          @document.footnotes&.footnote_entries,
          @document.endnotes&.endnote_entries,
          @document.comments&.comments,
        ].flatten.compact
      end
    end
  end
end
