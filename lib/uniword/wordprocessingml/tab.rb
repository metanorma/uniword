# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Tab character
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tab>
      class Tab < Lutaml::Model::Serializable


          xml do
            element 'tab'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

          end
      end
    end
end
