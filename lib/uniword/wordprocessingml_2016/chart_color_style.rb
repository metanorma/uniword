# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2016
    # Chart color style reference
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:chartColorStyle>
    class ChartColorStyle < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'chartColorStyle'
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute 'val', to: :val
      end
    end
  end
end
