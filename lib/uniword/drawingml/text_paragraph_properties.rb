# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Text paragraph properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:pPr>
    class TextParagraphProperties < Lutaml::Model::Serializable
      attribute :algn, :string
      attribute :marL, :integer
      attribute :marR, :integer

      xml do
        element 'pPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'algn', to: :algn
        map_attribute 'marL', to: :marL
        map_attribute 'marR', to: :marR
      end
    end
  end
end
