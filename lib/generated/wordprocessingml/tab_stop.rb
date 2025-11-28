# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Tab stop definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tabStop>
      class TabStop < Lutaml::Model::Serializable
          attribute :val, :string
          attribute :pos, :integer
          attribute :leader, :string

          xml do
            root 'tabStop'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
            map_attribute 'true', to: :pos
            map_attribute 'true', to: :leader
          end
      end
    end
  end
end
