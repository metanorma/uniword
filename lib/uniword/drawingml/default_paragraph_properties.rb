# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Default paragraph properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:defPPr>
    class DefaultParagraphProperties < Lutaml::Model::Serializable
      attribute :algn, :string
      attribute :lvl, :integer

      xml do
        element 'defPPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'algn', to: :algn
        map_attribute 'lvl', to: :lvl
      end
    end
  end
end
