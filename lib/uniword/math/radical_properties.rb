# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Radical formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:radPr>
    class RadicalProperties < Lutaml::Model::Serializable
      attribute :deg_hide, String
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'radPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_attribute 'val', to: :deg_hide
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
