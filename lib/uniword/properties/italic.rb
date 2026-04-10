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
      include Uniword::Properties::BooleanElement

      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'i'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end

    # Complex script italic
    class ItalicCs < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement

      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'iCs'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
