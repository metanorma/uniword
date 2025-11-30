# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # VML picture object
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:pict>
    class Picture < Lutaml::Model::Serializable
      attribute :shape, Shape

      xml do
        element 'pict'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'shape', to: :shape, render_nil: false
      end
    end
  end
end
