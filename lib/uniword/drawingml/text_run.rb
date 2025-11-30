# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Text run
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:r>
    class TextRun < Lutaml::Model::Serializable
      attribute :t, String

      xml do
        element 'r'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 't', to: :t
      end
    end
  end
end
