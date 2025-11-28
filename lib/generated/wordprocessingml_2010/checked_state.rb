# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Checked state symbol definition
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:checkedState>
      class CheckedState < Lutaml::Model::Serializable
          attribute :font, String
          attribute :val, String

          xml do
            root 'checkedState'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :font
            map_attribute 'true', to: :val
          end
      end
    end
  end
end
