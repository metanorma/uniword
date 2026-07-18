# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Text alignment enumeration
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:text_alignment>
    #
    # Value constrained to ST_TextAlignment (ECMA-376, wml.xsd).
    class TextAlignment < Lutaml::Model::Serializable
      # Full ST_TextAlignment enumeration from ECMA-376 (wml.xsd)
      VALUES = %w[top center baseline bottom auto].freeze

      attribute :val, :string, values: VALUES

      xml do
        element "text_alignment"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
