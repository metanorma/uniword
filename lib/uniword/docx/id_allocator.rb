# frozen_string_literal: true

require "digest"

module Uniword
  module Docx
    # Single owner of all ID assignment in a DOCX package.
    #
    # Every builder, the adapter, and the reconciler call into this class
    # for rId, footnote, endnote, bookmark, comment, and paragraph ID
    # allocation. No other code generates IDs.
    #
    # Two usage modes:
    #   Creating from scratch — allocator starts empty, all IDs are fresh.
    #   Editing a template   — call seed_from_* methods BEFORE any builder
    #                           runs, so new IDs don't collide with existing ones.
    #
    # This is the "populate-first" principle: when loading a template DOCX,
    # parse and seed ALL existing IDs from the template before modification.
    class IdAllocator
      REL_TYPE_BASE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

      IMAGE_REL_TYPE = "#{REL_TYPE_BASE}/image"
      HEADER_REL_TYPE = "#{REL_TYPE_BASE}/header"
      FOOTER_REL_TYPE = "#{REL_TYPE_BASE}/footer"
      HYPERLINK_REL_TYPE = "#{REL_TYPE_BASE}/hyperlink"
      CHART_REL_TYPE = "#{REL_TYPE_BASE}/chart"
      FOOTNOTES_REL_TYPE = "#{REL_TYPE_BASE}/footnotes"
      ENDNOTES_REL_TYPE = "#{REL_TYPE_BASE}/endnotes"
      THEME_REL_TYPE = "#{REL_TYPE_BASE}/theme"
      NUMBERING_REL_TYPE = "#{REL_TYPE_BASE}/numbering"

      def initialize
        @rid_counter = 0
        @rid_entries = {}  # [target, type] -> { id, type, target, target_mode }
        @footnote_counter = 1
        @endnote_counter = 1
        @bookmark_counter = 0
        @comment_counter = 0
        @para_counter = 0
        @rsid_counter = 0
      end

      # Allocate a relationship ID for a target+type pair.
      # Returns existing rId if this target+type was already registered.
      def alloc_rid(target:, type:, target_mode: nil)
        key = [target, type.to_s]
        @rid_entries[key] ||= begin
          @rid_counter += 1
          { id: "rId#{@rid_counter}", type: type.to_s,
            target: target, target_mode: target_mode }
        end
        @rid_entries[key][:id]
      end

      def alloc_footnote_id
        id = @footnote_counter
        @footnote_counter += 1
        id
      end

      def alloc_endnote_id
        id = @endnote_counter
        @endnote_counter += 1
        id
      end

      def alloc_bookmark_id
        @bookmark_counter += 1
        @bookmark_counter.to_s
      end

      def alloc_comment_id
        @comment_counter += 1
        @comment_counter.to_s
      end

      def alloc_para_id
        @para_counter += 1
        Digest::SHA256.hexdigest("para:#{@para_counter}").upcase[0, 12]
      end

      def alloc_rsid
        @rsid_counter += 1
        Digest::SHA256.hexdigest("rsid:#{@rsid_counter}").upcase[0, 12]
      end

      # Seed from a relationships collection — preserves existing rIds.
      def seed_from_rels(relationships)
        return unless relationships

        relationships.each do |r|
          key = [r.target, r.type.to_s]
          @rid_entries[key] = {
            id: r.id,
            type: r.type.to_s,
            target: r.target,
            target_mode: r.target_mode,
          }
          num = r.id[/\ArId(\d+)\z/, 1]&.to_i || 0
          @rid_counter = [@rid_counter, num].max
        end
      end

      # Seed footnote/endnote counters from existing note entries.
      def seed_from_notes(footnote_entries, endnote_entries)
        footnote_entries&.each do |e|
          id = e.id.to_i
          @footnote_counter = [@footnote_counter, id + 1].max if id > 0
        end
        endnote_entries&.each do |e|
          id = e.id.to_i
          @endnote_counter = [@endnote_counter, id + 1].max if id > 0
        end
      end

      # Produce the final ordered list of all allocated relationships.
      def all_rels
        @rid_entries.values.sort_by { |r| r[:id][/\d+/]&.to_i || 0 }
      end

      # Check if a relationship has been registered for a target+type.
      def rid_for(target:, type:)
        key = [target, type.to_s]
        @rid_entries[key]&.fetch(:id, nil)
      end

      # Build an allocator seeded from every source on a package in one call.
      # Used by both Package#populate_allocator and DocumentBuilder.from_template
      # so they cannot drift apart.
      def self.populate_from_package(package)
        alloc = new
        alloc.seed_from_rels(package.document_rels&.relationships)
        alloc.seed_from_rels(package.package_rels&.relationships)
        alloc.seed_from_notes(
          package.footnotes&.footnote_entries,
          package.endnotes&.endnote_entries,
        )
        alloc
      end
    end
  end
end
