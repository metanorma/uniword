# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Chart space root element
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:chartSpace>
    class ChartSpace < Lutaml::Model::Serializable
      attribute :date1904, :string
      attribute :lang, :string
      attribute :chart, Chart
      attribute :sp_pr, :string
      attribute :tx_pr, :string
      attribute :external_data, :string
      attribute :print_settings, :string

      xml do
        element 'chartSpace'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_attribute 'date1904', to: :date1904
        map_attribute 'lang', to: :lang
        map_element 'chart', to: :chart
        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'txPr', to: :tx_pr, render_nil: false
        map_element 'externalData', to: :external_data, render_nil: false
        map_element 'printSettings', to: :print_settings, render_nil: false
      end
    end
  end
end
