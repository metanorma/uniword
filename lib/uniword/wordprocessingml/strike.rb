# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Strikethrough formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:strike>
    class Strike < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'strike'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
