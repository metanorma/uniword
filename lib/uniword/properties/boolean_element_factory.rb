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
    end

    # Helper to define val= override after attribute declaration.
    # Uses alias_method to save the generated setter, then overrides it.
    module BooleanValSetter
      def self.included(base)
        base.class_eval do
          alias_method :__original_val_setter=, :val= if method_defined?(:val=)
          define_method(:val=) do |v|
            @val = if v.nil?
                     nil
                   elsif v == false || v.to_s == "false"
                     "false"
                   elsif v == true || v.to_s == "true"
                     nil
                   else
                     v
                   end
            value_set_for(:val)
          end
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
