# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Tab character
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tab>
      class Tab < Lutaml::Model::Serializable


          xml do
            root 'tab'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

          end
      end
    end
  end
end
