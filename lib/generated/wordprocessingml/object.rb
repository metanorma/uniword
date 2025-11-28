# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Embedded object
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:object>
      class Object < Lutaml::Model::Serializable
          attribute :dxaOrig, :integer
          attribute :dyaOrig, :integer

          xml do
            root 'object'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :dxaOrig
            map_attribute 'true', to: :dyaOrig
          end
      end
    end
  end
end
