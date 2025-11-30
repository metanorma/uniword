# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Chart title
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:title>
    class Title < Lutaml::Model::Serializable
      attribute :tx, :string
      attribute :layout, Layout
      attribute :overlay, :string
      attribute :sp_pr, :string
      attribute :tx_pr, :string

      xml do
        element 'title'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'tx', to: :tx, render_nil: false
        map_element 'layout', to: :layout, render_nil: false
        map_element 'overlay', to: :overlay, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'txPr', to: :tx_pr, render_nil: false
      end
    end
  end
end
