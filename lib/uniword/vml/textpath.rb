# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML text path for WordArt and watermarks
    #
    # Element: <v:textpath>
    class TextPath < Lutaml::Model::Serializable
      attribute :string, :string
      attribute :style, :string
      attribute :on, :string

      xml do
        element "textpath"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "string", to: :string
        map_attribute "style", to: :style, render_nil: false
        map_attribute "on", to: :on, render_nil: false
      end
    end
  end
end
