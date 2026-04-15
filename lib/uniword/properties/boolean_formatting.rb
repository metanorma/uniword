# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # OOXML boolean element mixin for value/val getter logic only.
    # The val= setter must be defined AFTER attribute :val to override
    # the generated setter.
    module BooleanElement
      def value
        @val != "false"
      end

      def value=(v)
        @val = v ? nil : "false"
      end
    end

    # Helper to define val= override after attribute declaration.
    # Uses alias_method to save the generated setter, then overrides it.
    module BooleanValSetter
      def self.included(base)
        base.class_eval do
          # Save the generated val= method
          alias_method :__original_val_setter=, :val= if method_defined?(:val=)
          # Override val= with our custom logic
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
            value_set_for(:val) if @val
          end
        end
      end
    end

    # Strike-through formatting
    class Strike < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "strike"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Double strike-through formatting
    class DoubleStrike < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "dstrike"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Small caps formatting
    class SmallCaps < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "smallCaps"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # All caps formatting
    class Caps < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "caps"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Hidden text
    class Vanish < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "vanish"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Web hidden text (hidden from web view)
    class WebHidden < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "webHidden"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # No proofing (disable spell/grammar check)
    class NoProof < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "noProof"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Shadow formatting
    class Shadow < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "shadow"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Emboss formatting
    class Emboss < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "emboss"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Imprint formatting
    class Imprint < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "imprint"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Style-level boolean elements

    # Quick format flag
    class QuickFormat < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "qFormat"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Keep with next paragraph
    class KeepNext < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "keepNext"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end

    # Keep lines together
    class KeepLines < Lutaml::Model::Serializable
      include BooleanElement

      attribute :val, :string, default: nil
      include BooleanValSetter

      xml do
        element "keepLines"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end
