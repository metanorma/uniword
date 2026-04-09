# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Text shadow effect
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:shadow>
    class TextShadow < Lutaml::Model::Serializable
      attribute :blur_radius, :integer
      attribute :distance, :integer
      attribute :direction, :integer
      attribute :alignment, :string

      xml do
        element 'shadow'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'blur-radius', to: :blur_radius
        map_attribute 'distance', to: :distance
        map_attribute 'direction', to: :direction
        map_attribute 'alignment', to: :alignment
      end
    end
  end
end
