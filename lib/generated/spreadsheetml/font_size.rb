# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Font size
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sz>
      class FontSize < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'sz'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
