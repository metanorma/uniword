# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Shadow text effect
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:shadow>
    class Shadow < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'shadow'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
