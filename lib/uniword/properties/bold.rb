# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Bold formatting element
    #
    # Represents <w:b w:val="..."/> or <w:b/> (empty = true)
    class Bold < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }

      xml do
        element 'b'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end

    # Complex script bold
    class BoldCs < Lutaml::Model::Serializable
      attribute :value, :boolean, default: -> { true }

      xml do
        element 'bCs'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end
  end
end
