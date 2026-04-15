# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2016
    # Enhanced chart style reference
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:chartStyle>
    class ChartStyle2016 < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "chartStyle"
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute "val", to: :val
      end
    end
  end
end
