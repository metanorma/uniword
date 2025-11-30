# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Default run properties container
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:rPrDefault>
      class RPrDefault < Lutaml::Model::Serializable
          attribute :rPr, RunProperties

          xml do
            element 'rPrDefault'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'rPr', to: :rPr, render_nil: false
          end
      end
    end
end
