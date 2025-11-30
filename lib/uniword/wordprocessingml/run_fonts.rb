# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'rFonts'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'ascii', to: :ascii
            map_attribute 'hAnsi', to: :hAnsi
            map_attribute 'cs', to: :cs
            map_attribute 'eastAsia', to: :eastAsia
          end
      end
    end
end
