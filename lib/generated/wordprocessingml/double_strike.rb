# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Double strikethrough formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:dstrike>
      class DoubleStrike < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'dstrike'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
