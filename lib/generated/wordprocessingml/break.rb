# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Line or page break
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:br>
      class Break < Lutaml::Model::Serializable
          attribute :type, :string
          attribute :clear, :string

          xml do
            root 'br'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :clear
          end
      end
    end
  end
end
