# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Vertical text alignment (superscript/subscript)
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:vertAlign>
    class VertAlign < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'vertAlign'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
