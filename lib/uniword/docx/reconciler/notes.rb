# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Footnote and endnote reconciliation.
      #
      # Ensures notes are structurally valid with separators, proper ordering
      # and sequential IDs. Creates missing notes/settings pairs and strips
      # invalid types.
      module Notes
        def reconcile_note_references
          [:footnote, :endnote].each do |type|
            ref_ids = collect_note_ids(type)
            next if ref_ids.empty?

            current = notes_collection_for(type)

            if current.nil?
              ensure_notes_part(type)
              current = notes_collection_for(type)
            end

            defined_set = note_entries_for(current, type).map(&:id).to_set

            missing = ref_ids.reject { |id| defined_set.include?(id) }
            next if missing.empty?

            entries = note_entries_for(current, type)
            missing.each do |id|
              entries << entry_class(type).new(
                id: id,
                paragraphs: [Wordprocessingml::Paragraph.new(
                  runs: [Wordprocessingml::Run.new(
                    text: Wordprocessingml::Text.new(content: " ")
                  )]
                )],
              )
            end
            record_fix(FixCodes::NOTE_DEFINITION_CREATED,
                       "Created missing #{type}note definitions for ids=#{missing.join(', ')}")
          end
        end

        def reconcile_footnotes
          reconcile_notes_type(
            notes: package.footnotes,
            notes_setter: ->(v) { package.footnotes = v },
            has_pr: package.settings&.footnote_pr,
            type: :footnote,
            create_message: "Created footnotes.xml to match footnotePr in settings",
            pr_message: "Added footnotePr to settings to match footnotes.xml",
          )
        end

        def reconcile_endnotes
          reconcile_notes_type(
            notes: package.endnotes,
            notes_setter: ->(v) { package.endnotes = v },
            has_pr: package.settings&.endnote_pr,
            type: :endnote,
            create_message: "Created endnotes.xml to match endnotePr in settings",
            pr_message: "Added endnotePr to settings to match endnotes.xml",
          )
        end

        private

        def reconcile_notes_type(notes:, notes_setter:, has_pr:, type:,
                                 create_message:, pr_message:)
          if has_pr && !notes
            notes_setter.call(minimal_notes(type))
            record_fix(FixCodes::NOTE_PAIR_CREATED, create_message)
          elsif notes && !has_pr
            package.settings ||= Wordprocessingml::Settings.new
            assign_note_pr(package.settings, type)
            record_fix(FixCodes::NOTE_PAIR_CREATED, pr_message)
          end

          current = notes_collection_for(type)
          return unless current

          entries = note_entries_for(current, type)

          finalize_notes(current, entries, type)
        end

        def finalize_notes(notes, entries, type)
          ensure_separators(notes, type, entries)
          strip_invalid_note_types(entries, type)
          deduplicate_note_ids(entries, type)
          strip_empty_runs_from_notes(entries)
          reorder_notes_by_reference(entries, type)

          unless allocator
            prefix = type == :footnote ? "fn" : "en"

            entries.each_with_index do |entry, eidx|
              backfill_paragraphs(entry.paragraphs, generate_rsid,
                                  "#{prefix}:#{eidx}")
            end

            renumber_notes(entries, type)
          end

          set_mc_ignorable(notes, prefixes: FULL_IGNORABLE)
        end

        def minimal_notes(type)
          entries = [separator_entry(type), continuation_entry(type)]
          build_notes_collection(type, entries: entries)
        end

        def entry_class(type)
          type == :footnote ? Wordprocessingml::Footnote : Wordprocessingml::Endnote
        end

        def separator_entry(type)
          entry_class(type).new(
            id: "-1", type: "separator",
            paragraphs: [separator_paragraph(:separator)]
          )
        end

        def continuation_entry(type)
          entry_class(type).new(
            id: "0", type: "continuationSeparator",
            paragraphs: [separator_paragraph(:continuation)]
          )
        end

        def separator_paragraph(kind = :separator)
          sep_attr = kind == :separator ? :separator_char : :continuation_separator_char
          sep_class = kind == :separator ? Wordprocessingml::SeparatorChar : Wordprocessingml::ContinuationSeparatorChar
          sep_run = Wordprocessingml::Run.new(sep_attr => sep_class.new)
          Wordprocessingml::Paragraph.new(
            properties: Wordprocessingml::ParagraphProperties.new(
              spacing: Properties::Spacing.new(after: 0, line: 240,
                                               line_rule: "auto"),
            ),
            runs: [sep_run]
          )
        end

        def ensure_separators(notes, type, entries)
          entries.each do |entry|
            next unless %w[separator continuationSeparator].include?(entry.type)
            next if entry.paragraphs.empty?

            entry.paragraphs.each do |p|
              strip_empty_runs(p)
              ensure_separator_run(p, entry.type)
            end
          end

          ids = entries.to_set(&:id)
          entries.unshift(separator_entry(type)) unless ids.include?("-1")
          entries.unshift(continuation_entry(type)) unless ids.include?("0")
        end

        def ensure_separator_run(para, type)
          has_sep = para.runs.any? { |r| r.separator_char || r.continuation_separator_char }
          return if has_sep

          sep = if type == "separator"
                  Wordprocessingml::Run.new(separator_char: Wordprocessingml::SeparatorChar.new)
                else
                  Wordprocessingml::Run.new(continuation_separator_char: Wordprocessingml::ContinuationSeparatorChar.new)
                end
          para.runs << sep
        end

        def strip_invalid_note_types(entries, type)
          stripped = []
          entries.each do |entry|
            next if VALID_NOTE_TYPES.include?(entry.type)
            next unless entry.type

            stripped << entry.id
            entry.type = nil
          end
          return if stripped.empty?

          record_fix(FixCodes::NOTE_INVALID_TYPE_STRIPPED,
                     "Stripped invalid w:type from #{type}note ids=#{stripped.join(', ')}")
        end

        def deduplicate_note_ids(entries, type)
          seen = {}
          dup_ids = []
          entries.reject! do |entry|
            if seen[entry.id]
              dup_ids << entry.id
              true
            else
              seen[entry.id] = true
              false
            end
          end
          return if dup_ids.empty?

          record_fix(FixCodes::NOTE_DUPLICATE_ID_REMOVED,
                     "Removed duplicate #{type}note ids=#{dup_ids.join(', ')}")
        end

        def reorder_notes_by_reference(entries, type)
          body = package.document&.body
          return unless body

          ref_order = collect_note_reference_order(body, type)
          return if ref_order.empty?

          structural = entries.select { |e| VALID_NOTE_TYPES.include?(e.type) }
          user_entries = entries.reject { |e| VALID_NOTE_TYPES.include?(e.type) }
          return if user_entries.size <= 1

          by_id = user_entries.group_by(&:id)
          reordered = ref_order.filter_map { |id| by_id[id]&.first }

          referenced_ids = ref_order.to_set
          unreferenced = user_entries.reject { |e| referenced_ids.include?(e.id) }
          reordered.concat(unreferenced)

          return if reordered == user_entries

          entries.clear
          structural.each { |e| entries << e }
          reordered.each { |e| entries << e }

          record_fix(FixCodes::NOTE_PAIR_CREATED, "Reordered #{type}notes by first reference in document body")
        end

        def renumber_notes(entries, type)
          user_entries = entries.reject { |e| VALID_NOTE_TYPES.include?(e.type) }
          return if user_entries.size <= 1

          id_map = {}
          user_entries.each_with_index do |entry, idx|
            old_id = entry.id
            new_id = (idx + 1).to_s
            next if old_id == new_id
            id_map[old_id] = new_id
            entry.id = new_id
          end
          return if id_map.empty?

          body = package.document&.body
          return unless body

          walk_body_paragraphs(body) do |para|
            para.runs.each do |run|
              ref = note_reference_from_run(run, type)
              next unless ref && ref.id && id_map.key?(ref.id)
              ref.id = id_map[ref.id]
            end
          end

          record_fix(FixCodes::NOTE_PAIR_CREATED, "Renumbered #{type}note IDs sequentially (#{id_map.size} changed)")
        end

        def collect_note_reference_order(body, type)
          seen = []

          walk_body_paragraphs(body) do |para|
            para.runs.each do |run|
              ref = note_reference_from_run(run, type)
              next unless ref && ref.id
              seen << ref.id unless seen.include?(ref.id)
            end
          end

          seen
        end

        # note_reference_from_run lives in Helpers (single source for note-type dispatch).

        def collect_note_ids(type)
          ids = []
          body = package.document&.body
          return ids unless body

          walk_body_paragraphs(body) do |para|
            para.runs.each do |run|
              ref = note_reference_from_run(run, type)
              ids << ref.id if ref&.id
            end
          end
          ids
        end

        def ensure_notes_part(type)
          notes = build_notes_collection(
            type,
            entries: [separator_entry(type), continuation_entry(type)],
          )
          set_notes_collection(notes, type)
        end
      end
    end
  end
end
