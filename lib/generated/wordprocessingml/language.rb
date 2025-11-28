# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Language settings
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:lang>
      class Language < Lutaml::Model::Serializable
          attribute :val, :string
          attribute :eastAsia, :string
          attribute :bidi, :string

          xml do
            root 'lang'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
            map_attribute 'true', to: :eastAsia
            map_attribute 'true', to: :bidi
          end
      end
    end
  end
end
