# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Document default formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:docDefaults>
      class DocDefaults < Lutaml::Model::Serializable
          attribute :rPrDefault, RPrDefault
          attribute :pPrDefault, PPrDefault

          xml do
            root 'docDefaults'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'rPrDefault', to: :rPrDefault, render_nil: false
            map_element 'pPrDefault', to: :pPrDefault, render_nil: false
          end
      end
    end
  end
end
