# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # X values for scatter/bubble charts
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:xVal>
    class XValues < Lutaml::Model::Serializable
      attribute :num_ref, NumberReference
      attribute :num_lit, :string

      xml do
        element 'xVal'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'numRef', to: :num_ref, render_nil: false
        map_element 'numLit', to: :num_lit, render_nil: false
      end
    end
  end
end
