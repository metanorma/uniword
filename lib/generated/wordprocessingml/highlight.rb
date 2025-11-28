# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Text highlight color
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:highlight>
      class Highlight < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'highlight'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
