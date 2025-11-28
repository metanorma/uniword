# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Phonetic properties for East Asian text
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:phoneticPr>
      class PhoneticProperties < Lutaml::Model::Serializable
          attribute :font_id, Integer
          attribute :type, String

          xml do
            root 'phoneticPr'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :font_id
            map_attribute 'true', to: :type
          end
      end
    end
  end
end
