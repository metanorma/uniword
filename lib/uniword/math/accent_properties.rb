# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Accent formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:accPr>
    class AccentProperties < Lutaml::Model::Serializable
      attribute :chr, Char
      attribute :ctrl_pr, ControlProperties

      xml do
        element "accPr"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "chr", to: :chr, render_nil: false
        map_element "ctrlPr", to: :ctrl_pr, render_nil: false
      end
    end
  end
end
