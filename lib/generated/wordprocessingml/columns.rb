# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Column layout definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:cols>
      class Columns < Lutaml::Model::Serializable
          attribute :num, :integer
          attribute :space, :integer
          attribute :separate, :boolean

          xml do
            root 'cols'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :num
            map_attribute 'true', to: :space
            map_attribute 'true', to: :separate
          end
      end
    end
  end
end
