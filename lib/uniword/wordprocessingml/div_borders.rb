# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class DivBorders < Lutaml::Model::Serializable
      attribute :top, DivBorder
      attribute :left, DivBorder
      attribute :bottom, DivBorder
      attribute :right, DivBorder

      xml do
        element "divBdr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "top", to: :top, render_nil: false
        map_element "left", to: :left, render_nil: false
        map_element "bottom", to: :bottom, render_nil: false
        map_element "right", to: :right, render_nil: false
      end
    end
  end
end
