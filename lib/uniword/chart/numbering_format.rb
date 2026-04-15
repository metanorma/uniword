# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Number format
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:numFmt>
    class NumberingFormat < Lutaml::Model::Serializable
      attribute :format_code, :string
      attribute :source_linked, :string

      xml do
        element "numFmt"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "formatCode", to: :format_code
        map_attribute "sourceLinked", to: :source_linked
      end
    end
  end
end
