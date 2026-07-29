# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # OOXML boolean element mixin for value/val getter logic only.
    # The val= setter must be defined AFTER attribute :val to override
    # the generated setter.
    module BooleanElement
      def value
        val != "false"
      end

      # ST_OnOff accepts 0/1, false/true and off/on. An absent w:val means the
      # toggle is on, and nil is not in FALSE_VALUES, so it falls through.
      # Unknown tokens read as on: a reader must not raise on a malformed doc.
      def on?
        !Ooxml::Types::OoxmlBoolean::FALSE_VALUES.include?(val)
      end
    end

    # Helper to define val= override after attribute declaration.
    module BooleanValSetter
      def self.included(base)
        base.define_method(:val=) do |v|
          @val = case v
                 when nil then nil
                 when false, "false" then "false"
                 when true, "true" then nil
                 else v
                 end
          value_set_for(:val)
        end
      end
    end

    # Factory for OOXML boolean element classes.
    #
    # Generates a lutaml-model class that maps to an XML element like
    # <w:b/> (true) or <w:b w:val="false"/> (false).
    #
    # @param element_name [String] XML element name (e.g. "b", "i", "strike")
    # @param class_name [String] Ruby class name (e.g. "Bold", "Italic")
    # @return [Class] The generated class, also assigned as a constant
    #
    # @example
    #   BooleanElementFactory.define("b", "Bold")
    #   BooleanElementFactory.define("bCs", "BoldCs")
    module BooleanElementFactory
      WML_NS = Uniword::Ooxml::Namespaces::WordProcessingML

      def self.define(element_name, class_name)
        klass = Class.new(Lutaml::Model::Serializable) do
          include BooleanElement

          attribute :val, :string, default: nil
          include BooleanValSetter

          xml do
            element element_name
            namespace WML_NS
            map_attribute "val", to: :val, render_nil: false,
                                 render_default: false
          end
        end

        Properties.const_set(class_name, klass)
        klass
      end
    end
  end
end
