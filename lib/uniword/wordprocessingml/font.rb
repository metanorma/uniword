# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Font definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:font>
    class Font < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :charset, :string
      attribute :family, :string
      attribute :pitch, :string

      xml do
        element 'font'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'name', to: :name
        map_attribute 'charset', to: :charset
        map_attribute 'family', to: :family
        map_attribute 'pitch', to: :pitch
      end
    end
  end
end
