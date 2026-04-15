# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Extension element for custom or future features
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:ext>
    class Extension < Lutaml::Model::Serializable
      attribute :uri, :string

      xml do
        element "ext"
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute "uri", to: :uri
      end
    end
  end
end
