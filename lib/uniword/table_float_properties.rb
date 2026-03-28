# frozen_string_literal: true

require 'lutaml/model'



module Uniword
  module TableFloatProperties
    # Table float properties for docx.js compatibility
    #
    # This class provides a flat API for table float properties
    # that mirrors the docx.js TableFloatProperties interface.
    class TableFloatProperties < Lutaml::Model::Serializable
      attribute :alignment, :string
      attribute :spacing_before, :integer
      attribute :spacing_after, :integer
      attribute :width, :integer
      attribute :borders, Borders
      attribute :shading, Shading

      xml do
        element "tableFloatProperties"
        namespace nil

        map_attribute 'alignment', to: :alignment
        map_attribute 'spacingBefore', to: :spacing_before
        map_attribute 'spacingAfter', to: :spacing_after
        map_attribute 'width', to: :width
        map_element 'borders', to: :borders
        map_element 'shading', to: :shading
      end
    end
  end
end
