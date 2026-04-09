# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Border definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:border>
    class Border < Lutaml::Model::Serializable
      attribute :left, :string
      attribute :right, :string
      attribute :top, :string
      attribute :bottom, :string
      attribute :diagonal, :string

      xml do
        element 'border'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'left', to: :left, render_nil: false
        map_element 'right', to: :right, render_nil: false
        map_element 'top', to: :top, render_nil: false
        map_element 'bottom', to: :bottom, render_nil: false
        map_element 'diagonal', to: :diagonal, render_nil: false
      end
    end
  end
end
