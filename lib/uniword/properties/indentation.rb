# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Paragraph indentation element
    #
    # Represents <w:ind> with left, right, firstLine, and hanging attributes
    class Indentation < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :left, :integer
      attribute :right, :integer
      attribute :first_line, :integer
      attribute :hanging, :integer

      xml do
        element 'ind'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'left', to: :left
        map_attribute 'right', to: :right
        map_attribute 'firstLine', to: :first_line
        map_attribute 'hanging', to: :hanging
      end
    end
  end
end