# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Base style reference
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:basedOn>
      class BasedOn < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'basedOn'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
