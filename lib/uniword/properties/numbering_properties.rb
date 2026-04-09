# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Numbering properties wrapper element
    #
    # Represents <w:numPr> containing <w:numId> and <w:ilvl> child elements.
    # Used in paragraph properties for list item formatting.
    class NumberingProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :num_id, NumberingId
      attribute :ilvl, NumberingLevel

      xml do
        element 'numPr'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'numId', to: :num_id, render_nil: false
        map_element 'ilvl', to: :ilvl, render_nil: false
      end
    end
  end
end
