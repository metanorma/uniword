# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Numbering instance
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:num>
    class Num < Lutaml::Model::Serializable
      attribute :numId, :integer
      attribute :abstractNumId, AbstractNumId

      xml do
        element "num"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "numId", to: :numId
        map_element "abstractNumId", to: :abstractNumId, render_nil: false
      end
    end
  end
end
