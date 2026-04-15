# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Pre-sub-superscript formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:sPrePr>
    class PreSubSuperscriptProperties < Lutaml::Model::Serializable
      attribute :ctrl_pr, ControlProperties

      xml do
        element "sPrePr"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "ctrlPr", to: :ctrl_pr, render_nil: false
      end
    end
  end
end
