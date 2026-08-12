# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Shared reading and writing behaviour for OOXML ST_OnOff elements.
    #
    # The val= setter must be defined AFTER attribute :val to override
    # the generated setter, so includers pull in BooleanValSetter separately.
    module BooleanElement
      # Move a `value:` key onto `val:`.
      #
      # lutaml-model drops constructor keys it does not know, so
      # `Bold.new(value: "0")` used to build an ON toggle and throw the
      # argument away. An explicit `val:` still wins.
      #
      # @param attrs [Hash, Object] Constructor arguments
      # @return [Hash, Object] Arguments with `value` renamed to `val`
      def self.alias_value_key(attrs)
        return attrs unless attrs.is_a?(Hash)

        key = [:value, "value"].find { |k| attrs.key?(k) }
        return attrs if key.nil?

        attrs = attrs.dup
        aliased = attrs.delete(key)
        attrs[:val] = aliased unless attrs.key?(:val) || attrs.key?("val")
        attrs
      end

      def initialize(attrs = {})
        super(BooleanElement.alias_value_key(attrs))
      end

      # ST_OnOff (ECMA-376 §17.17.4) spells off as "0", "false" or "off".
      # An absent w:val means the toggle is on. Unknown tokens read as on:
      # a reader must not raise on a malformed document.
      #
      # @return [Boolean] true when the toggle is on
      def on?
        Ooxml::Types::OoxmlBoolean.on?(val)
      end

      # One reading for every consumer.
      #
      # This used to be `val != "false"`, which read "0" and "off" as on.
      # Word shows both as off.
      #
      # @return [Boolean] true when the toggle is on
      def value
        on?
      end

      # @param new_value [Object] Any ST_OnOff spelling, or a Ruby boolean
      def value=(new_value)
        self.val = new_value
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
