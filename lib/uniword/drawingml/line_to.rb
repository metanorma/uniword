# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Line to command
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lnTo>
    class LineTo < Lutaml::Model::Serializable
      attribute :pt, :string

      xml do
        element 'lnTo'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'pt', to: :pt
      end
    end
  end
end
