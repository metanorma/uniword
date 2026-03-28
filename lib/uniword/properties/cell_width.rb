# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Table cell width specification
    #
    # Represents <w:tcW> element with width value and type.
    # Used in table cell properties to specify cell dimensions.
    #
    # @example Creating cell width
    #   width = CellWidth.new(w: 2500, type: 'pct')
    class CellWidth < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :w, :integer        # Width value
      attribute :type, :string      # Width type: auto, dxa (twips), pct (percentage), nil

      xml do
        element "tcW"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'w', to: :w
        map_attribute 'type', to: :type, render_nil: false
      end
    end
  end
end
