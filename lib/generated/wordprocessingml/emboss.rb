# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Emboss text effect
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:emboss>
      class Emboss < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'emboss'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
