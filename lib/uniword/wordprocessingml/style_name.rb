# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Style name
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:name>
    class StyleName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'name'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
