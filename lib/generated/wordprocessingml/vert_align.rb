# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Vertical text alignment (superscript/subscript)
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:vertAlign>
      class VertAlign < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'vertAlign'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
