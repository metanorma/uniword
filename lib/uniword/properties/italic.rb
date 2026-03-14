# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Italic formatting element
    class Italic < Lutaml::Model::Serializable
      attribute :value, :boolean

      xml do
        element 'i'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Complex script italic
    class ItalicCs < Lutaml::Model::Serializable
      attribute :value, :boolean

      xml do
        element 'iCs'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end
  end
end
