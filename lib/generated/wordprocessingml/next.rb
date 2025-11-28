# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Next paragraph style
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:next>
      class Next < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'next'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
