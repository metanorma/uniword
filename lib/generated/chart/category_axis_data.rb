# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Category axis data
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:cat>
      class CategoryAxisData < Lutaml::Model::Serializable
          attribute :str_ref, :string
          attribute :num_ref, NumberReference
          attribute :str_lit, :string
          attribute :num_lit, :string

          xml do
            root 'cat'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'strRef', to: :str_ref, render_nil: false
            map_element 'numRef', to: :num_ref, render_nil: false
            map_element 'strLit', to: :str_lit, render_nil: false
            map_element 'numLit', to: :num_lit, render_nil: false
          end
      end
    end
  end
end
