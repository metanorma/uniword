# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Conditional formatting style reference
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:cnfStyle>
      class ConditionalFormatStyle < Lutaml::Model::Serializable
          attribute :val, String
          attribute :first_row, String
          attribute :last_row, String
          attribute :first_column, String
          attribute :last_column, String

          xml do
            root 'cnfStyle'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :val
            map_attribute 'true', to: :first_row
            map_attribute 'true', to: :last_row
            map_attribute 'true', to: :first_column
            map_attribute 'true', to: :last_column
          end
      end
    end
  end
end
