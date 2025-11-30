# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Chart properties for embedded charts
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:chartProps>
    class ChartProps < Lutaml::Model::Serializable
      attribute :style, :string
      attribute :color_mapping, :string

      xml do
        element 'chartProps'
        namespace Uniword::Ooxml::Namespaces::Word2012
        mixed_content

        map_attribute 'style', to: :style
        map_element 'colorMapping', to: :color_mapping, render_nil: false
      end
    end
  end
end
