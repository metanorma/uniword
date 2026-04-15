# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Non-visual drawing properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:cNvPr>
    class NonVisualDrawingProperties < Lutaml::Model::Serializable
      attribute :id, :integer
      attribute :name, :string
      attribute :descr, :string
      attribute :title, :string
      attribute :hidden, :string

      xml do
        element "cNvPr"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "id", to: :id
        map_attribute "name", to: :name
        map_attribute "descr", to: :descr
        map_attribute "title", to: :title
        map_attribute "hidden", to: :hidden
      end
    end
  end
end
