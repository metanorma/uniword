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
    #
    # rId namespaces are per relationships part: "rId1" in _rels/.rels and
    # "rId1" in word/_rels/document.xml.rels do not collide. The allocator
    # therefore tracks rIds per +scope+ (:document for document-level rels,
    # :package for package-level rels); each scope has its own registry,
    # counter and uniqueness domain.
    class IdAllocator
      # Relationship type namespace base (also the r: namespace URI).
      # Individual rel type constants derive from Ooxml::PartRegistry,
      # the single source of truth for part metadata.
      REL_TYPE_BASE = Ooxml::PartRegistry::OFFICE_REL_BASE

      IMAGE_REL_TYPE = Ooxml::PartRegistry.find_by_key(:image).rel_type
      HEADER_REL_TYPE = Ooxml::PartRegistry.find_by_key(:header).rel_type
      FOOTER_REL_TYPE = Ooxml::PartRegistry.find_by_key(:footer).rel_type
      HYPERLINK_REL_TYPE = Ooxml::PartRegistry.find_by_key(:hyperlink).rel_type
      CHART_REL_TYPE = Ooxml::PartRegistry.find_by_key(:chart).rel_type
      FOOTNOTES_REL_TYPE = Ooxml::PartRegistry.find_by_key(:footnotes).rel_type
      ENDNOTES_REL_TYPE = Ooxml::PartRegistry.find_by_key(:endnotes).rel_type
      THEME_REL_TYPE = Ooxml::PartRegistry.find_by_key(:theme).rel_type
      NUMBERING_REL_TYPE = Ooxml::PartRegistry.find_by_key(:numbering).rel_type

      def initialize
        @rid_counters = Hash.new(0) # scope -> high-water mark
        # [scope, target, type] -> { id, type, target, target_mode, scope }
        @rid_entries = {}
        @footnote_counter = 1
        @endnote_counter = 1
        @bookmark_counter = 0
        @comment_counter = 0
        @para_counter = 0
        @rsid_counter = 0
      end

      # Allocate a relationship ID for a target+type pair.
      # Returns existing rId if this target+type was already registered.
      #
      # @param target [String] relationship target
      # @param type [String] relationship type
      # @param target_mode [String, nil] e.g. "External"
      # @param scope [Symbol] :document or :package (rels part namespace)
      # @return [String] the allocated (or existing) rId
      def alloc_rid(target:, type:, target_mode: nil, scope: :document)
        key = [scope, target, type.to_s]
        @rid_entries[key] ||= begin
          @rid_counters[scope] += 1
          @rid_counters[scope] += 1 while rid_id_taken?(
            "rId#{@rid_counters[scope]}", scope
          )
          { id: "rId#{@rid_counters[scope]}", type: type.to_s,
            target: target, target_mode: target_mode, scope: scope }
        end
        @rid_entries[key][:id]
      end

      # Register an explicit rId for a target+type pair.
      # Used when a relationship id is assigned outside the counter
      # (rId dedup repair) so later lookups stay consistent.
      #
      # @param id [String] relationship ID to register
      # @param target [String] relationship target
      # @param type [String] relationship type
      # @param target_mode [String, nil] e.g. "External"
      # @param scope [Symbol] :document or :package
      # @return [String] the registered id
      def register_rid(id, target:, type:, target_mode: nil, scope: :document)
        @rid_entries[[scope, target, type.to_s]] = {
          id: id, type: type.to_s, target: target, target_mode: target_mode,
          scope: scope
        }
        num = id[/\ArId(\d+)\z/, 1]&.to_i || 0
        @rid_counters[scope] = [@rid_counters[scope], num].max
        id
      end

      # The next free rId past the high-water mark of a scope —
      # guaranteed not registered to any target+type in that scope.
      #
      # @param scope [Symbol] :document or :package
      # @return [String] e.g. "rId7"
      def next_free_rid(scope: :document)
        candidate = @rid_counters[scope] + 1
        candidate += 1 while rid_id_taken?("rId#{candidate}", scope)
        "rId#{candidate}"
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
        Digest::SHA256.hexdigest("para:#{@para_counter}").upcase[0, 8]
      end

      def alloc_rsid
        @rsid_counter += 1
        Digest::SHA256.hexdigest("rsid:#{@rsid_counter}").upcase[0, 8]
      end

      # Seed from a relationships collection — preserves existing rIds
      # verbatim so a load→save round-trip is rId-stable. A loaded rId
      # already registered to a different target+type in the same scope
      # (only possible when allocation preceded seeding, or the source
      # has duplicate ids) yields a fresh counter allocation for the
      # seeded pair instead — uniqueness wins over verbatim preservation.
      #
      # @param relationships [Array, nil] rels to seed
      # @param scope [Symbol] :document or :package (rels part namespace)
      def seed_from_rels(relationships, scope: :document)
        return unless relationships

        relationships.each { |r| seed_rel(r, scope) }
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

      # Seed the comment counter from existing comment entries so newly
      # allocated comment IDs do not collide with loaded ones.
      def seed_from_comments(comments)
        comments&.each do |c|
          @comment_counter = [@comment_counter, c.comment_id.to_i].max
        end
      end

      # Produce the final ordered list of all allocated relationships.
      #
      # @param scope [Symbol, nil] restrict to one scope; nil for all
      def all_rels(scope: nil)
        entries = @rid_entries.values
        entries = entries.select { |r| r[:scope] == scope } if scope
        entries.sort_by { |r| r[:id][/\d+/]&.to_i || 0 }
      end

      # Check if a relationship has been registered for a target+type.
      def rid_for(target:, type:, scope: :document)
        key = [scope, target, type.to_s]
        @rid_entries[key]&.fetch(:id, nil)
      end

      # Build an allocator seeded from every source on a package in one call.
      # Used by both Package#populate_allocator and DocumentBuilder.from_template
      # so they cannot drift apart.
      def self.populate_from_package(package)
        alloc = new
        alloc.seed_from_rels(package.document_rels&.relationships)
        alloc.seed_from_rels(package.package_rels&.relationships,
                             scope: :package)
        alloc.seed_from_notes(
          package.footnotes&.footnote_entries,
          package.endnotes&.endnote_entries,
        )
        alloc.seed_from_comments(comment_entries_of(package))
        alloc
      end

      # Comment entries of a package or document, tolerating the legacy
      # Array form of DocumentRoot#comments.
      def self.comment_entries_of(source)
        part = source.comments
        part.is_a?(Uniword::CommentsPart) ? part.comments : part
      end
      private_class_method :comment_entries_of

      private

      # Seed one relationship (see seed_from_rels for the collision rule).
      def seed_rel(rel, scope)
        key = [scope, rel.target, rel.type.to_s]
        return if @rid_entries.key?(key)

        if rid_id_taken?(rel.id, scope)
          alloc_rid(target: rel.target, type: rel.type,
                    target_mode: rel.target_mode, scope: scope)
          return
        end

        register_rid(rel.id, target: rel.target, type: rel.type,
                           target_mode: rel.target_mode, scope: scope)
      end

      # Whether an rId string is already registered within a scope.
      def rid_id_taken?(id, scope)
        @rid_entries.any? do |key, entry|
          key[0] == scope && entry[:id] == id
        end
      end
    end
  end
end
