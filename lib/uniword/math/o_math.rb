# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Office Math object - container for mathematical expressions
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:oMath>
    #
    # When created via from_xml, the original inner XML is preserved so
    # to_xml can emit it verbatim. This prevents data loss through the
    # typed-collection round-trip (subscripts, fractions, etc. lose
    # child text during deserialization/reserialization).
    class OMath < Lutaml::Model::Serializable
      include Uniword::HasRunPosition

      # Pattern 0: Attributes BEFORE xml mappings
      attribute :runs, MathRun, collection: true, initialize_empty: true
      attribute :functions, Function, collection: true, initialize_empty: true
      attribute :fractions, Fraction, collection: true, initialize_empty: true
      attribute :superscripts, Superscript, collection: true,
                                            initialize_empty: true
      attribute :subscripts, Subscript, collection: true, initialize_empty: true
      attribute :sub_superscripts, SubSuperscript, collection: true,
                                                   initialize_empty: true
      attribute :delimiters, Delimiter, collection: true, initialize_empty: true
      attribute :radicals, Radical, collection: true, initialize_empty: true
      attribute :narys, Nary, collection: true, initialize_empty: true
      attribute :boxes, Box, collection: true, initialize_empty: true
      attribute :accents, Accent, collection: true, initialize_empty: true
      attribute :bars, Bar, collection: true, initialize_empty: true
      attribute :group_chars, GroupChar, collection: true,
                                         initialize_empty: true
      attribute :border_boxes, BorderBox, collection: true,
                                          initialize_empty: true
      attribute :matrices, Matrix, collection: true, initialize_empty: true
      attribute :equation_arrays, EquationArray, collection: true,
                                                 initialize_empty: true

      # Transient: position among sibling runs (used by MHTML renderer)
      attribute :run_position, :integer

      # Raw inner XML preserved from from_xml for lossless round-trip.
      # When set, to_xml emits this verbatim instead of the typed
      # collections.
      attr_accessor :raw_inner_xml

      def self.from_xml(xml_string)
        omath = super
        doc = Nokogiri::XML(xml_string)
        omath_node = doc.root || doc.at_xpath("//*[local-name()='oMath']")
        if omath_node
          omath.raw_inner_xml = omath_node.inner_html
        end
        omath
      end

      # When raw_inner_xml is set (from from_xml), emit the verbatim
      # content instead of going through the lossy typed-collection
      # round-trip.
      def to_xml(options = {})
        return build_raw_xml if raw_inner_xml

        super
      end

      private

      def build_raw_xml
        ns = Uniword::Ooxml::Namespaces::MathML.new.uri
        %(<oMath xmlns="#{ns}">#{raw_inner_xml}</oMath>)
      end

      xml do
        element "oMath"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "r", to: :runs, render_nil: false
        map_element "func", to: :functions, render_nil: false
        map_element "f", to: :fractions, render_nil: false
        map_element "sSup", to: :superscripts, render_nil: false
        map_element "sSub", to: :subscripts, render_nil: false
        map_element "sSubSup", to: :sub_superscripts, render_nil: false
        map_element "d", to: :delimiters, render_nil: false
        map_element "rad", to: :radicals, render_nil: false
        map_element "nary", to: :narys, render_nil: false
        map_element "box", to: :boxes, render_nil: false
        map_element "acc", to: :accents, render_nil: false
        map_element "bar", to: :bars, render_nil: false
        map_element "groupChr", to: :group_chars, render_nil: false
        map_element "borderBox", to: :border_boxes, render_nil: false
        map_element "m", to: :matrices, render_nil: false
        map_element "eqArr", to: :equation_arrays, render_nil: false
      end
    end
  end
end
