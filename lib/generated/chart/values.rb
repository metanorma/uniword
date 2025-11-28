# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Value axis data
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:val>
      class Values < Lutaml::Model::Serializable
          attribute :num_ref, NumberReference
          attribute :num_lit, :string

          xml do
            root 'val'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'numRef', to: :num_ref, render_nil: false
            map_element 'numLit', to: :num_lit, render_nil: false
          end
      end
    end
  end
end
