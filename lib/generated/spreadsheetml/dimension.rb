# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Sheet dimensions
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:dimension>
      class Dimension < Lutaml::Model::Serializable
          attribute :ref, String

          xml do
            root 'dimension'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :ref
          end
      end
    end
  end
end
