# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Miter line join
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:miter>
    class LineJoinMiter < Lutaml::Model::Serializable
      attribute :lim, :integer

      xml do
        element 'miter'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'lim', to: :lim
      end
    end
  end
end
