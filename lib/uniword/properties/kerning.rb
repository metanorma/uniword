# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for kerning value
    class KerningValue < Lutaml::Model::Type::Integer
    end

    # Kerning threshold element
    #
    # Represents <w:kern w:val="..."/> where value is:
    # - Integer in half-points
    # - Specifies font size threshold for automatic kerning
    # - 0 = kerning disabled
    # - Typical values: 8-72 (4pt to 36pt threshold)
    class Kerning < Lutaml::Model::Serializable
      attribute :value, KerningValue

      xml do
        element 'kern'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
