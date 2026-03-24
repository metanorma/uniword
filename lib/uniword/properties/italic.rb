# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Italic formatting element
    #
    # OOXML: <w:i/> means italic=true (absence of val= means true)
    # <w:i w:val="false"/> means italic=false
    #
    # Model: nil = true (no val attribute), 'false' = explicit false
    class Italic < Lutaml::Model::Serializable
      attribute :val, :string, default: nil

      # Ruby convenience
      def value
        @val != 'false'
      end

      def value=(v)
        @val = v ? nil : 'false'
      end

      # Override the generated val= with proper conversion
      def val=(v)
        @val = if v.nil?
                 nil
               elsif v == false || v.to_s == 'false'
                 'false'
               elsif v == true || v.to_s == 'true'
                 nil
               else
                 v
               end
      end

      xml do
        element 'i'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end

    # Complex script italic
    class ItalicCs < Lutaml::Model::Serializable
      attribute :val, :string, default: nil

      def value
        @val != 'false'
      end

      def value=(v)
        @val = v ? nil : 'false'
      end

      def val=(v)
        @val = if v.nil?
                 nil
               elsif v == false || v.to_s == 'false'
                   'false'
                 elsif v == true || v.to_s == 'true'
                   nil
                 else
                   v
                 end
      end

      xml do
        element 'iCs'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
