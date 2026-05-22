# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class WebDivs < Lutaml::Model::Serializable
      attribute :div, WebDiv, collection: true

      xml do
        element "divs"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "div", to: :div, render_nil: false
      end
    end
  end
end
