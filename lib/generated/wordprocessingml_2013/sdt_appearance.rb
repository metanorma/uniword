# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # SDT appearance settings for Word 2013+
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:appearance>
      class SdtAppearance < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'appearance'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
