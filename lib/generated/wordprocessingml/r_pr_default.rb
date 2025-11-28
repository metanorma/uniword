# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Default run properties container
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:rPrDefault>
      class RPrDefault < Lutaml::Model::Serializable
          attribute :rPr, RunProperties

          xml do
            root 'rPrDefault'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'rPr', to: :rPr, render_nil: false
          end
      end
    end
  end
end
