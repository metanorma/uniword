# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Text direction wrapper
    # XML: <w:textDirection w:val="lrTb"/>
    class TextDirection < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "textDirection"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :value, render_nil: false
      end
    end
  end
end
