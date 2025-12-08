# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Default paragraph properties container
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:pPrDefault>
    class PPrDefault < Lutaml::Model::Serializable
      attribute :pPr, Uniword::Ooxml::WordProcessingML::ParagraphProperties

      xml do
        element 'pPrDefault'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'pPr', to: :pPr, render_nil: false
      end
    end
  end
end
