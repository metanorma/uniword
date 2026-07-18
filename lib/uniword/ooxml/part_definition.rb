# frozen_string_literal: true

module Uniword
  module Ooxml
    # Declarative description of one OOXML package part kind.
    #
    # A PartDefinition is the single source of truth for a part's
    # package path, content type, relationship type, and the form its
    # [Content_Types].xml entry takes (Default by extension or Override
    # by part name). Instances are immutable value objects registered
    # in {PartRegistry}; consumers derive every literal from them.
    #
    # Parts with instance-numbered paths (headers, footers, charts,
    # customXml items) carry a +path_pattern+/+target_pattern+ with
    # +format+-style placeholders (e.g. "word/header%<counter>d.xml")
    # instead of a fixed path.
    #
    # @example Fixed part
    #   PartDefinition.new(
    #     key: :styles, path: "word/styles.xml", target: "styles.xml",
    #     content_type: "...styles+xml",
    #     rel_type: ".../relationships/styles",
    #     required: true, kind: :override, rels_scope: :document,
    #   )
    class PartDefinition
      # @return [Symbol] unique registry key (e.g. :styles)
      attr_reader :key

      # @return [String, nil] package-relative path ("word/styles.xml")
      attr_reader :path

      # @return [String, nil] path template for instance-numbered parts
      attr_reader :path_pattern

      # @return [String, nil] relationship Target as written in .rels
      #   (relative to the owning part; defaults to +path+)
      attr_reader :target

      # @return [String, nil] Target template for numbered parts
      attr_reader :target_pattern

      # @return [String, nil] MIME content type (nil when dynamic,
      #   e.g. images whose type depends on the file extension)
      attr_reader :content_type

      # @return [String, nil] relationship type URI (nil when the part
      #   is not referenced by a relationship)
      attr_reader :rel_type

      # @return [String, nil] file extension for Default entries
      attr_reader :extension

      # @return [Boolean] whether a minimal valid package carries it
      attr_reader :required

      # @return [Symbol] :override, :default, or :none (no
      #   [Content_Types].xml entry of its own)
      attr_reader :kind

      # @return [Symbol, nil] :package or :document — which .rels part
      #   the relationship lives in (nil when +rel_type+ is nil)
      attr_reader :rels_scope

      # @return [Boolean] whether ContentTypes.generate includes it in
      #   the comprehensive [Content_Types].xml for new DOCX packages
      attr_reader :standard

      # rubocop:disable Metrics/ParameterLists
      def initialize(key:, kind:, path: nil, path_pattern: nil,
                     target: nil, target_pattern: nil,
                     content_type: nil, rel_type: nil, extension: nil,
                     required: false, rels_scope: nil, standard: false)
        @key = key.to_sym
        @kind = kind
        @path = path
        @path_pattern = path_pattern
        @target = target || path
        @target_pattern = target_pattern
        @content_type = content_type
        @rel_type = rel_type
        @extension = extension
        @required = required
        @rels_scope = rels_scope
        @standard = standard
      end
      # rubocop:enable Metrics/ParameterLists

      # @return [Boolean] true for [Content_Types].xml Override entries
      def override?
        kind == :override
      end

      # @return [Boolean] true for [Content_Types].xml Default entries
      def default?
        kind == :default
      end

      # @return [Boolean] true when a minimal valid package carries it
      def required?
        !!required
      end

      # @return [Boolean] true when ContentTypes.generate includes it
      def standard?
        !!standard
      end

      # @return [Boolean] true when the relationship lives in _rels/.rels
      def package_rel?
        rels_scope == :package
      end

      # Resolve the package-relative path, interpolating pattern
      # placeholders for instance-numbered parts.
      #
      # @param vars [Hash] placeholder values (e.g. counter: 1)
      # @return [String, nil] e.g. "word/header1.xml"
      def path_for(**vars)
        expand(path_pattern || path, vars)
      end

      # Resolve the content-type Override part name (leading slash).
      #
      # @param vars [Hash] placeholder values for numbered parts
      # @return [String, nil] e.g. "/word/header1.xml"
      def part_name_for(**vars)
        resolved = path_for(**vars)
        resolved && "/#{resolved}"
      end

      # Resolve the relationship Target attribute.
      #
      # @param vars [Hash] placeholder values for numbered parts
      # @return [String, nil] e.g. "header1.xml"
      def target_for(**vars)
        expand(target_pattern || target, vars)
      end

      # Fixed-path Override part name (leading slash).
      #
      # @return [String, nil] e.g. "/word/styles.xml"
      def part_name
        path && "/#{path}"
      end

      # Two definitions are equal when every field matches.
      def ==(other)
        other.is_a?(PartDefinition) && fields == other.fields
      end

      protected

      # @return [Array] field values in declaration order, used for
      #   value equality
      def fields
        [key, kind, path, path_pattern, target, target_pattern,
         content_type, rel_type, extension, required, rels_scope,
         standard]
      end

      private

      def expand(template, vars)
        return nil unless template
        return template if vars.empty?

        format(template, vars)
      end
    end
  end
end
