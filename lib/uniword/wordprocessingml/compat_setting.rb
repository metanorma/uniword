# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
        element 'compatSetting'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'name', to: :name
        map_attribute 'uri', to: :uri
        map_attribute 'val', to: :val
      end
    end
  end
end
