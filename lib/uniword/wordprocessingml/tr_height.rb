# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table row height wrapper
    # XML: <w:trHeight w:val="..." w:hRule="..."/>
    class TrHeight < Lutaml::Model::Serializable
      attribute :value, :integer
      attribute :height_rule, :string

      xml do
        element "trHeight"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :value, render_nil: false
        map_attribute "hRule", to: :height_rule, render_nil: false
      end
    end
  end
end
