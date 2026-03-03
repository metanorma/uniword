# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Visual appearance mode for Structured Document Tag
    # Values: "hidden", "tags", "boundingBox"
    # Reference XML: <w:appearance w:val="hidden"/>
    class Appearance < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'appearance'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
