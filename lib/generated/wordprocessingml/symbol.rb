# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Symbol character
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:sym>
      class Symbol < Lutaml::Model::Serializable
          attribute :font, :string
          attribute :char, :string

          xml do
            root 'sym'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :font
            map_attribute 'true', to: :char
          end
      end
    end
  end
end
