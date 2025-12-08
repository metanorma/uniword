# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Control properties for math objects
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:ctrlPr>
    class ControlProperties < Lutaml::Model::Serializable
      # Pattern 0: Attribute BEFORE xml mapping
      attribute :run_properties, Uniword::Wordprocessingml::RunProperties

      xml do
        element 'ctrlPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'rPr', to: :run_properties,
                    namespace: Uniword::Ooxml::Namespaces::WordProcessingML,
                    render_nil: false
      end
    end
  end
end
