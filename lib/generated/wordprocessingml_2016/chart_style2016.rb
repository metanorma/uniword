# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Enhanced chart style reference
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:chartStyle>
      class ChartStyle2016 < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'chartStyle'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
