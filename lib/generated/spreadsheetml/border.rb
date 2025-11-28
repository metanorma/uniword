# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Border definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:border>
      class Border < Lutaml::Model::Serializable
          attribute :left, String
          attribute :right, String
          attribute :top, String
          attribute :bottom, String
          attribute :diagonal, String

          xml do
            root 'border'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
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
end
