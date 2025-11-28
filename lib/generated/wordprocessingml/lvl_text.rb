# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Level text format
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:lvlText>
      class LvlText < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'lvlText'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
