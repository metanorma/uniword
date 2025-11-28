# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Italic formatting
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:i>
      class Italic < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'i'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
