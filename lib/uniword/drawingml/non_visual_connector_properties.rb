# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Non-visual connector properties
    #
    # Element: <a:cNvCxnSpPr>
    class NonVisualConnectorProperties < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element 'cNvCxnSpPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'id', to: :id
      end
    end
  end
end
