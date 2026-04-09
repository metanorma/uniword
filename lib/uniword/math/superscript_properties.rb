# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Superscript formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:sSupPr>
    class SuperscriptProperties < Lutaml::Model::Serializable
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'sSupPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
