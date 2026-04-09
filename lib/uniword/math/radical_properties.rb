# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Radical formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:radPr>
    class RadicalProperties < Lutaml::Model::Serializable
      attribute :deg_hide, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'radPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'degHide', to: :deg_hide, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
