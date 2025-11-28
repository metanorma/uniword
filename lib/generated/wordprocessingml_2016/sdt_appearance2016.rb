# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Enhanced SDT appearance for accessibility
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:sdtAppearance>
      class SdtAppearance2016 < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'sdtAppearance'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
