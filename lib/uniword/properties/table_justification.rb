# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Table justification element
    #
    # Represents <w:jc> element with val attribute for table alignment.
    # Used in table properties (w:tblPr) for table positioning.
    class TableJustification < Lutaml::Model::Serializable
      # Full ST_JcTable enumeration from ECMA-376 (wml.xsd)
      VALUES = %w[center end left right start].freeze

      attribute :value, :string, values: VALUES

      xml do
        element "jc"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end
    end
  end
end
