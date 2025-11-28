# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Major gridlines
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:majorGridlines>
      class MajorGridlines < Lutaml::Model::Serializable
          attribute :sp_pr, :string

          xml do
            root 'majorGridlines'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'spPr', to: :sp_pr, render_nil: false
          end
      end
    end
  end
end
