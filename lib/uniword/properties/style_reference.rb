# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Style reference element for paragraph styles
    #
    # Represents <w:pStyle w:val="..."/> where value is the style ID
    class StyleReference < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'pStyle'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end

    # Style reference element for character/run styles
    #
    # Represents <w:rStyle w:val="..."/> where value is the style ID
    class RunStyleReference < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'rStyle'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
