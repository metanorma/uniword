# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Number reference to spreadsheet
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:numRef>
      class NumberReference < Lutaml::Model::Serializable
          attribute :f, :string
          attribute :num_cache, :string

          xml do
            root 'numRef'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'f', to: :f
            map_element 'numCache', to: :num_cache, render_nil: false
          end
      end
    end
  end
end
