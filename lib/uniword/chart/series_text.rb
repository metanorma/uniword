# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Series text
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:tx>
    class SeriesText < Lutaml::Model::Serializable
      attribute :str_ref, :string
      attribute :v, :string

      xml do
        element 'tx'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'strRef', to: :str_ref, render_nil: false
        map_element 'v', to: :v, render_nil: false
      end
    end
  end
end
