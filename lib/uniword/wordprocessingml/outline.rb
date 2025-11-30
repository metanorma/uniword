# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Outline text effect
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:outline>
    class Outline < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'outline'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
