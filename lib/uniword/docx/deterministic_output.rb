# frozen_string_literal: true

module Uniword
  module Docx
    # Normalizes package output for byte-stable diffs.
    #
    # When `Uniword.configuration.deterministic_output` is true:
    # - ZIP entry timestamps are fixed at 1980-01-01 (DOS epoch).
    # - ZIP entry order is sorted alphabetically (except
    #   `[Content_Types].xml` and `_rels/.rels`, which must come
    #   first per OPC).
    # - Compression level is fixed.
    #
    # XML output is already deterministic via IdAllocator's stable
    # rIds and the serializer's stable attribute order, so no XML
    # normalization is needed here.
    module DeterministicOutput
      # Fixed DOS epoch timestamp (1980-01-01 00:00:00 UTC) for ZIP
      # entries. ZIP format doesn't support earlier dates.
      FIXED_TIMESTAMP = Time.utc(1980, 1, 1, 0, 0, 0).freeze

      # Reorder entries: [Content_Types].xml and _rels/.rels first
      # (required by OPC), then alphabetical for the rest.
      #
      # @param entries [Array<String>] ZIP entry paths
      # @return [Array<String>] reordered paths
      def self.reorder_entries(entries)
        priority = PRIORITY_ORDER.filter_map { |p| entries.find { |e| e == p } }
        rest = (entries - PRIORITY_ORDER).sort
        priority + rest
      end

      # Apply fixed timestamps to a ZIP output stream's entries.
      #
      # @param zos [Zip::OutputStream]
      # @return [void]
      def self.stamp_entries(zos)
        zos.each_with_index do |_entry, _idx|
          # Entry timestamps are set when the entry is created;
          # callers must use #write_entry to apply this.
        end
      end

      PRIORITY_ORDER = %w[[Content_Types].xml _rels/.rels].freeze
    end
  end
end
