# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Font kerning
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:kern>
      class Kerning < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'kern'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
