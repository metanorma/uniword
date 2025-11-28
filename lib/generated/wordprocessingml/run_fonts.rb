# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Run font information
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:rFonts>
      class RunFonts < Lutaml::Model::Serializable
          attribute :ascii, :string
          attribute :hAnsi, :string
          attribute :cs, :string
          attribute :eastAsia, :string

          xml do
            root 'rFonts'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :ascii
            map_attribute 'true', to: :hAnsi
            map_attribute 'true', to: :cs
            map_attribute 'true', to: :eastAsia
          end
      end
    end
  end
end
