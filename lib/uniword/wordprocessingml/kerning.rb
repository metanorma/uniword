# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Font kerning
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:kern>
    class Kerning < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'kern'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
