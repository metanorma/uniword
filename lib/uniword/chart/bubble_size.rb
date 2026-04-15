# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Bubble size data
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:bubbleSize>
    class BubbleSize < Lutaml::Model::Serializable
      attribute :num_ref, NumberReference
      attribute :num_lit, :string

      xml do
        element "bubbleSize"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "numRef", to: :num_ref, render_nil: false
        map_element "numLit", to: :num_lit, render_nil: false
      end
    end
  end
end
