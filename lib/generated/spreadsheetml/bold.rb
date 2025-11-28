# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Bold formatting
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:b>
      class Bold < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'b'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
