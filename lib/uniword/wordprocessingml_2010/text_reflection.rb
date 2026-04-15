# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Text reflection effect
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:reflection>
    class TextReflection < Lutaml::Model::Serializable
      attribute :blur_radius, :integer
      attribute :start_opacity, :integer
      attribute :end_opacity, :integer
      attribute :distance, :integer

      xml do
        element "reflection"
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute "blur-radius", to: :blur_radius
        map_attribute "start-opacity", to: :start_opacity
        map_attribute "end-opacity", to: :end_opacity
        map_attribute "distance", to: :distance
      end
    end
  end
end
