# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Paragraph spacing element
    #
    # Represents <w:spacing> with before, after, line, and lineRule attributes
    class Spacing < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :before, :integer
      attribute :after, :integer
      attribute :line, :integer
      attribute :line_rule, :string

      xml do
        element 'spacing'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'before', to: :before
        map_attribute 'after', to: :after
        map_attribute 'line', to: :line
        map_attribute 'lineRule', to: :line_rule
      end
    end
  end
end
