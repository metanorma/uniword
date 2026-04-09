# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Grid column definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:gridCol>
    class GridCol < Lutaml::Model::Serializable
      attribute :width, :integer

      xml do
        element 'gridCol'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'w', to: :width
      end
    end
  end
end
