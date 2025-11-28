# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Font definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:font>
      class Font < Lutaml::Model::Serializable
          attribute :name, :string
          attribute :charset, :string
          attribute :family, :string
          attribute :pitch, :string

          xml do
            root 'font'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :charset
            map_attribute 'true', to: :family
            map_attribute 'true', to: :pitch
          end
      end
    end
  end
end
