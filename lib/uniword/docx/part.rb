# frozen_string_literal: true

module Uniword
  module Docx
    # Value object for one package-held part (chart, embedding,
    # header, footer, ...).
    #
    # A Part couples the part's content (a lutaml-model object or a
    # raw String) with the packaging metadata the OPC layer needs to
    # emit it: relationship target, relationship id, content type and
    # relationship type. Defaults for the metadata come from the
    # part's Ooxml::PartDefinition (the single source of truth);
    # loaded documents may carry verbatim overrides (e.g. strict-OOXML
    # relationship URIs).
    #
    # Replaces the raw Hash entries previously stored in
    # +chart_parts+, +embeddings+ and +header_footer_parts+. Hash-style
    # read access (+part[:target]+) is kept for backward compatibility.
    #
    # @example
    #   part = Part.new(
    #     definition: Ooxml::PartRegistry.find_by_key(:ole_object),
    #     target: "embeddings/file.xlsx",
    #     content: binary_data,
    #   )
    #   part.path         # => "word/embeddings/file.xlsx"
    #   part.content_type # => definition's content type
    class Part
      # @return [Ooxml::PartDefinition, nil] registry definition for
      #   this part kind
      attr_reader :definition

      # @return [String, nil] relationship id (nil until wired)
      attr_accessor :r_id

      # @return [String, nil] relationship target relative to word/
      attr_accessor :target

      # @return [Object] part content (model object or raw String)
      attr_accessor :content

      # @param definition [Ooxml::PartDefinition, nil] registry entry
      # @param r_id [String, nil] relationship id
      # @param target [String, nil] relationship target (relative to
      #   the owning part, e.g. "charts/chart1.xml")
      # @param content [Object, nil] part content
      # @param rel_type [String, nil] explicit relationship type
      #   override (verbatim value from a loaded package)
      # @param content_type [String, nil] explicit content type
      #   override (verbatim value from a loaded package)
      # rubocop:disable Metrics/ParameterLists
      def initialize(definition: nil, r_id: nil, target: nil, content: nil,
                     rel_type: nil, content_type: nil)
        @definition = definition
        @r_id = r_id
        @target = target
        @content = content
        @rel_type = rel_type
        @content_type = content_type
      end
      # rubocop:enable Metrics/ParameterLists

      # Wrap a legacy raw-hash entry ({ content:/xml:, target: }) into
      # a Part. Subclasses override for family-specific keys (e.g.
      # ImagePart's { data:, content_type:, path: }). Used by
      # PartCollection to normalize hash assignments.
      #
      # @param hash [Hash] legacy hash entry
      # @return [Part]
      def self.from_hash(hash)
        new(target: hash[:target], content: hash[:content] || hash[:xml])
      end

      # @return [String, nil] relationship type URI
      def rel_type
        @rel_type || definition&.rel_type
      end

      # @return [String, nil] MIME content type
      def content_type
        @content_type || definition&.content_type
      end

      # Package-relative path of the emitted part. Document-scoped
      # parts live under word/; their target is already relative to
      # word/.
      #
      # @return [String, nil] e.g. "word/charts/chart1.xml"
      def path
        target && "word/#{target}"
      end

      # Package paths this part emits (one for plain parts; subclasses
      # with sidecar parts override).
      #
      # @return [Array<String>] emitted package paths
      def package_paths
        [path].compact
      end

      # Verbatim overrides carried from a loaded package.
      attr_writer :rel_type, :content_type

      # Key → reader lambdas backing hash-style access (kept as data
      # so the dispatch stays declarative).
      HASH_LOOKUP = {
        r_id: lambda(&:r_id),
        target: lambda(&:target),
        rel_type: lambda(&:rel_type),
        content_type: lambda(&:content_type),
        content: lambda(&:content),
        path: lambda(&:path),
      }.freeze

      # Hash-style read compatibility for former hash entries.
      #
      # @param key [Symbol, String] one of :r_id, :target, :rel_type,
      #   :content_type, :content, :path
      # @return [Object, nil]
      def [](key)
        HASH_LOOKUP[key.to_sym]&.call(self)
      end
    end
  end
end
