# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Chart tracking reference mode
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:chartTrackingRefBased>
    class ChartTrackingRefBased < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'chartTrackingRefBased'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
