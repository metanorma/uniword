# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Common data shared across all slide types
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:c_sld>
    class CommonSlideData < Lutaml::Model::Serializable
      attribute :bg, :string
      attribute :sp_tree, ShapeTree
      attribute :name, :string

      xml do
        element "c_sld"
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element "bg", to: :bg, render_nil: false
        map_element "spTree", to: :sp_tree
        map_attribute "name", to: :name
      end
    end
  end
end
