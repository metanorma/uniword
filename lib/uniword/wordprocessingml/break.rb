# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Line or page break
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:br>
    class Break < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :clear, :string

      xml do
        element "br"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "type", to: :type
        map_attribute "clear", to: :clear
      end
    end
  end
end
