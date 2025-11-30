# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Language settings
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:lang>
    class Language < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :eastAsia, :string
      attribute :bidi, :string

      xml do
        element 'lang'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
        map_attribute 'eastAsia', to: :eastAsia
        map_attribute 'bidi', to: :bidi
      end
    end
  end
end
