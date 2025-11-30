# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Column layout definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:cols>
    class Columns < Lutaml::Model::Serializable
      attribute :num, :integer
      attribute :space, :integer
      attribute :separate, :boolean

      xml do
        element 'cols'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'num', to: :num
        map_attribute 'space', to: :space
        map_attribute 'separate', to: :separate
      end
    end
  end
end
