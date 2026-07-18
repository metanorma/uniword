# frozen_string_literal: true

module Uniword
  module Docx
    # A header or footer part (word/headerN.xml / word/footerN.xml)
    # held by the package — the single storage form for both
    # round-tripped and builder-created headers/footers.
    #
    # Parts loaded from an existing DOCX carry their original +r_id+,
    # +target+ and +rel_type+ verbatim and are flagged +loaded+ so the
    # reconciler leaves their relationships and section references
    # untouched. Parts added programmatically (via the Builder or the
    # +headers+/+footers+ views) are flagged fresh: the reconciler
    # assigns them a relationship and wires the sectPr reference.
    #
    # The +type+ ("default"/"first"/"even") is the sectPr reference
    # type — derived from the section properties on load, set by the
    # caller on insert. Content is usually a
    # Wordprocessingml::Header or Wordprocessingml::Footer model;
    # legacy Uniword::Header/Uniword::Footer convenience models are
    # stored as given and converted at serialization time so callers
    # can keep mutating the object they inserted.
    class HeaderFooterPart < Part
      # Valid section reference types.
      TYPES = %w[default first even].freeze

      # @return [String, nil] sectPr reference type
      #   ("default"/"first"/"even")
      attr_accessor :type

      # @param kind [Symbol, nil] :header or :footer (derived from
      #   rel_type, target or content when omitted)
      # @param type [String, nil] sectPr reference type
      # @param loaded [Boolean] true when extracted verbatim from an
      #   existing package
      def initialize(kind: nil, type: nil, loaded: false, **rest)
        super(**rest)
        @kind = kind
        @type = type&.to_s
        @loaded = loaded
      end

      # @return [Symbol, nil] :header or :footer
      def kind
        @kind ||= derive_kind
      end

      # @return [Boolean] true for header parts
      def header?
        kind == :header
      end

      # @return [Boolean] true for footer parts
      def footer?
        kind == :footer
      end

      # @return [Boolean] true when extracted from an existing package
      #   (relationships and section references are already in place)
      def loaded?
        !!@loaded
      end

      # Mark whether the part originates from a loaded package.
      attr_writer :loaded

      # Registry definition for this part kind.
      #
      # @return [Ooxml::PartDefinition, nil]
      def definition
        @definition ||= kind && Ooxml::PartRegistry.find_by_key(kind)
      end

      # -- Content delegation (quacks like the content model) --

      # @return [Array<Wordprocessingml::Paragraph>] content paragraphs
      def paragraphs
        content&.paragraphs
      end

      # @return [Array<Wordprocessingml::Table>] content tables
      def tables
        content&.tables
      end

      # @return [Boolean] true when the content has no paragraphs/tables
      def empty?
        return true unless content

        paragraphs.empty? && tables.empty?
      end

      # Hash-style read compatibility (+:type+ in addition to the
      # Part keys).
      def [](key)
        key.to_sym == :type ? type : super
      end

      # The content model to serialize into the part file. Legacy
      # Uniword::Header/Uniword::Footer models are converted to their
      # Wordprocessingml counterparts (paragraph and table elements are
      # shared, mc:Ignorable carried over); other content passes
      # through unchanged.
      #
      # @return [Object] serializable content model
      def serializable_content
        case content
        when Uniword::Header
          convert_legacy(Wordprocessingml::Header.new)
        when Uniword::Footer
          convert_legacy(Wordprocessingml::Footer.new)
        else
          content
        end
      end

      private

      def convert_legacy(wml)
        wml.paragraphs.concat(content.paragraphs)
        wml.tables.concat(content.tables)
        wml.mc_ignorable = content.mc_ignorable if content.mc_ignorable
        wml
      end

      def derive_kind
        # rel_type (".../relationships/header") and target
        # ("header1.xml") both embed the kind word.
        carrier = "#{rel_type} #{target}"
        return :header if carrier.include?("header")
        return :footer if carrier.include?("footer")

        case content
        when Wordprocessingml::Header, Uniword::Header then :header
        when Wordprocessingml::Footer, Uniword::Footer then :footer
        end
      end
    end
  end
end
