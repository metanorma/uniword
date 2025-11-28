# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Sparkline groups collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sparklineGroups>
      class SparklineGroups < Lutaml::Model::Serializable
          attribute :groups, SparklineGroup, collection: true, default: -> { [] }

          xml do
            root 'sparklineGroups'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'sparklineGroup', to: :groups, render_nil: false
          end
      end
    end
  end
end
