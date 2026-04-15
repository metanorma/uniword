# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Table width specification
    #
    # Represents <w:tblW> element with width value and type.
    # Used in table properties to specify table dimensions.
    #
    # @example Creating table width
    #   width = TableWidth.new(w: 5000, type: 'pct')
    class TableWidth < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :w, :integer        # Width value
      attribute :type, :string      # Width type: auto, dxa (twips), pct (percentage), nil

      xml do
        element "tblW"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "w", to: :w
        map_attribute "type", to: :type, render_nil: false
      end
    end
  end
end
