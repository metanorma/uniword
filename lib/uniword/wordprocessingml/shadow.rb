# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Shadow text effect
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:shadow>
    class Shadow < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement

      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element "shadow"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val, render_nil: false, render_default: false
      end
    end
  end
end
