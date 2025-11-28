# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Individual compatibility setting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:compatSetting>
      class CompatSetting < Lutaml::Model::Serializable
          attribute :name, :string
          attribute :uri, :string
          attribute :val, :string

          xml do
            root 'compatSetting'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :uri
            map_attribute 'true', to: :val
          end
      end
    end
  end
end
