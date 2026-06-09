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
            record_fix("R9", create_message)
          elsif notes && !has_pr
            package.settings ||= Wordprocessingml::Settings.new
            case type
            when :footnote
              package.settings.footnote_pr = Wordprocessingml::FootnotePr.new
            when :endnote
              package.settings.endnote_pr = Wordprocessingml::EndnotePr.new
            end
            record_fix("R9", pr_message)
          end

          current = case type
                    when :footnote then package.footnotes
                    when :endnote then package.endnotes
                    end
          return unless current

          entries = case type
                    when :footnote then current.footnote_entries
                    when :endnote then current.endnote_entries
                    end

          finalize_notes(current, entries, type)
        end

        def finalize_notes(notes, entries, type)
          ensure_separators(notes, type, entries)
          strip_invalid_note_types(entries)
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
          case type
          when :footnote
            Wordprocessingml::Footnotes.new(footnote_entries: entries)
          when :endnote
            Wordprocessingml::Endnotes.new(endnote_entries: entries)
          end
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
              p.runs.reject! { |r| empty_run?(r) }
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

        def strip_invalid_note_types(entries)
          entries.each do |entry|
            next unless entry.type && !VALID_NOTE_TYPES.include?(entry.type)

            record_fix("R9",
                       "Stripped invalid w:type=\"#{entry.type}\" from " \
                       "note id=#{entry.id}")
            entry.type = nil
          end
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

          record_fix("R9", "Reordered #{type}notes by first reference in document body")
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

          record_fix("R9", "Renumbered #{type}note IDs sequentially (#{id_map.size} changed)")
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

        # Explicit type dispatch — no public_send.
        def note_reference_from_run(run, type)
          case type
          when :footnote then run.footnote_reference
          when :endnote then run.endnote_reference
          end
        end
      end
    end
  end
end
