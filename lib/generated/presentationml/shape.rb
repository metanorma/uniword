# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Individual shape on a slide
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sp>
      class Shape < Lutaml::Model::Serializable
          attribute :nv_sp_pr, NonVisualShapeProperties
          attribute :sp_pr, ShapeProperties
          attribute :tx_body, TextBody

          xml do
            root 'sp'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'nvSpPr', to: :nv_sp_pr
            map_element 'spPr', to: :sp_pr
            map_element 'txBody', to: :tx_body, render_nil: false
          end
      end
    end
  end
end
