# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Error bar type
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:errBarType>
      class ErrorBarType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'errBarType'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
