# frozen_string_literal: true

module Uniword
  module Ooxml
    # Declarative description of one OOXML package part kind.
    #
    # A PartDefinition is the single source of truth for a part's
    # package path, content type, relationship type, the form its
    # [Content_Types].xml entry takes (Default by extension or Override
    # by part name), how it is loaded from extracted ZIP content, and
    # where it lives on both Wordprocessingml::DocumentRoot and
    # Docx::Package. Instances are immutable value objects registered
    # in {PartRegistry}; consumers derive every literal from them.
    #
    # Parts with instance-numbered paths (headers, footers, charts,
    # customXml items) carry a +path_pattern+/+target_pattern+ with
    # +format+-style placeholders (e.g. "word/header%<counter>d.xml")
    # instead of a fixed path.
    #
    # Load behavior beyond this data (parse rules for special part
    # kinds) lives in named Docx::PartLoader strategy classes selected
    # by +loader+; the definition itself stays a value object.
    #
    # @example Fixed part
    #   PartDefinition.new(
    #     key: :styles, path: "word/styles.xml", target: "styles.xml",
    #     content_type: "...styles+xml",
    #     rel_type: ".../relationships/styles",
    #     required: true, kind: :override, rels_scope: :document,
    #     loader: :xml_model,
    #     loader_model: Uniword::Wordprocessingml::StylesConfiguration,
    #     load_priority: 50,
    #     package_attribute: :styles,
    #     document_attribute: :styles_configuration,
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

      # @return [Symbol, nil] Docx::PartLoader strategy key
      #   (:xml_model, :custom_xml, :header_footer, :chart, :image,
      #   :embedding, :theme_media); nil when the part is not loaded
      #   from ZIP content
      attr_reader :loader

      # @return [Class, nil] model class parsing the part's XML
      #   (responds to +.from_xml+); used by loaders that parse
      attr_reader :loader_model

      # @return [Symbol, nil] dynamic path resolution rule:
      #   :office_document (resolve the main document path from the
      #   package-level officeDocument relationship) or
      #   :office_document_rels (sidecar .rels of the resolved main
      #   document); nil for fixed paths
      attr_reader :path_resolution

      # @return [Integer, nil] load ordering weight — lower loads
      #   first; entries sharing a priority load in registration order
      attr_reader :load_priority

      # @return [Symbol, nil] attribute (reader/writer) holding this
      #   part on Wordprocessingml::DocumentRoot
      attr_reader :document_attribute

      # @return [Symbol, nil] attribute (reader/writer) holding this
      #   part on Docx::Package
      attr_reader :package_attribute

      # @return [Boolean] whether the package→document copy includes
      #   this part (false when the loader already places the part on
      #   the document, or the part is never read from ZIP content)
      attr_reader :copy_to_document

      # @return [Symbol, nil] predicate on the document guarding the
      #   document→package copy (e.g. :numbering_configuration_loaded?
      #   for the lazily-initialized numbering configuration)
      attr_reader :to_package_guard

      # @return [Class, nil] class the value must be an instance of
      #   for the document→package copy (e.g. CommentsPart, since
      #   DocumentRoot#comments can hold non-part values)
      attr_reader :to_package_type

      # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def initialize(key:, kind:, path: nil, path_pattern: nil,
                     target: nil, target_pattern: nil,
                     content_type: nil, rel_type: nil, extension: nil,
                     required: false, rels_scope: nil, standard: false,
                     loader: nil, loader_model: nil, path_resolution: nil,
                     load_priority: nil, document_attribute: nil,
                     package_attribute: nil, copy_to_document: true,
                     to_package_guard: nil, to_package_type: nil)
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
        @loader = loader
        @loader_model = loader_model
        @path_resolution = path_resolution
        @load_priority = load_priority
        @document_attribute = document_attribute
        @package_attribute = package_attribute
        @copy_to_document = copy_to_document
        @to_package_guard = to_package_guard
        @to_package_type = to_package_type
      end
      # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

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

      # @return [Boolean] true when the part loads from ZIP content
      def loadable?
        !loader.nil?
      end

      # @return [Boolean] true when the package→document copy mirrors
      #   this part onto Wordprocessingml::DocumentRoot
      def copy_to_document?
        !!copy_to_document
      end

      # Whether a package path matches this definition's fixed path or
      # path pattern. Accepts both "word/styles.xml" and
      # "/word/styles.xml" forms, and matches numbered paths against
      # the pattern ("word/header2.xml" → :header).
      #
      # @param candidate [String] package-relative path
      # @return [Boolean]
      def match_path?(candidate)
        normalized = candidate.to_s.delete_prefix("/")
        return true if path == normalized
        return false unless path_pattern

        normalized.match?(template_regex(path_pattern))
      end

      # Static prefix of the path pattern up to the first placeholder
      # (e.g. "word/theme/media/" for "word/theme/media/%<name>s").
      #
      # @return [String, nil] nil for fixed-path definitions
      def pattern_prefix
        path_pattern&.split(/%<\w+>[ds]/)&.first
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
      # rubocop:disable Metrics/AbcSize
      def fields
        [key, kind, path, path_pattern, target, target_pattern,
         content_type, rel_type, extension, required, rels_scope,
         standard, loader, loader_model, path_resolution,
         load_priority, document_attribute, package_attribute,
         copy_to_document, to_package_guard, to_package_type]
      end
      # rubocop:enable Metrics/AbcSize

      private

      def expand(template, vars)
        return nil unless template
        return template if vars.empty?

        format(template, vars)
      end

      # Convert a pattern like "word/header%<counter>d.xml" into a
      # matching regexp: %<name>d → digits, %<name>s → any path run.
      def template_regex(template)
        source = template.split(/(%<\w+>[ds])/).map do |part|
          case part
          when /%<\w+>d/ then "\\d+"
          when /%<\w+>s/ then ".+?"
          else Regexp.escape(part)
          end
        end.join
        /\A#{source}\z/
      end
    end
  end
end
