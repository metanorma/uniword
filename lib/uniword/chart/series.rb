# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Chart series base
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:ser>
    class Series < Lutaml::Model::Serializable
      attribute :idx, Index
      attribute :order, Order
      attribute :tx, SeriesText
      attribute :sp_pr, :string

      xml do
        element "ser"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "idx", to: :idx
        map_element "order", to: :order
        map_element "tx", to: :tx, render_nil: false
        map_element "spPr", to: :sp_pr, render_nil: false
      end
    end
  end
end
