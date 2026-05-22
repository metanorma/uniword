# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class WebDiv < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :body_div, BodyDiv
      attribute :mar_left, MarLeft
      attribute :mar_right, MarRight
      attribute :mar_top, MarTop
      attribute :mar_bottom, MarBottom
      attribute :div_bdr, DivBorders
      attribute :divs_child, DivsChild

      xml do
        element "div"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_attribute "id", to: :id
        map_element "bodyDiv", to: :body_div, render_nil: false
        map_element "marLeft", to: :mar_left, render_nil: false
        map_element "marRight", to: :mar_right, render_nil: false
        map_element "marTop", to: :mar_top, render_nil: false
        map_element "marBottom", to: :mar_bottom, render_nil: false
        map_element "divBdr", to: :div_bdr, render_nil: false
        map_element "divsChild", to: :divs_child, render_nil: false
      end
    end
  end
end

# Reopen DivsChild to add the recursive WebDiv reference
Uniword::Wordprocessingml::DivsChild.class_eval do
  attribute :div, Uniword::Wordprocessingml::WebDiv, collection: true

  xml do
    map_element "div", to: :div, render_nil: false
  end
end
