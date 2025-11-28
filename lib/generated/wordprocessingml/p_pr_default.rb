# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Default paragraph properties container
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:pPrDefault>
      class PPrDefault < Lutaml::Model::Serializable
          attribute :pPr, ParagraphProperties

          xml do
            root 'pPrDefault'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'pPr', to: :pPr, render_nil: false
          end
      end
    end
  end
end
