# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Sort state
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sortState>
      class SortState < Lutaml::Model::Serializable
          attribute :ref, String

          xml do
            root 'sortState'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :ref
          end
      end
    end
  end
end
