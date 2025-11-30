# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Field instruction text
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:instrText>
    class InstrText < Lutaml::Model::Serializable
      attribute :text, :string

      xml do
        element 'instrText'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'text', to: :text, render_nil: false
      end
    end
  end
end
