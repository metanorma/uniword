# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Text properties reference (DrawingML)
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:txPr>
    class TextProperties < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "txPr"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_element "", to: :content, render_nil: false
      end
    end
  end
end
