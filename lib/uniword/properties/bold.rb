# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Bold formatting element
    #
    # OOXML: <w:b/> means bold=true (absence of val= means true)
    # <w:b w:val="false"/> means bold=false
    #
    # Model: nil = true (no val attribute), 'false' = explicit false
    class Bold < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement
      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'b'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end

    # Complex script bold
    class BoldCs < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement
      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'bCs'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
