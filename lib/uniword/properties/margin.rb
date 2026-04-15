# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Margin specification helper
    # Represents individual margin with width and type
    class Margin < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :w, :integer        # Width in twips
      attribute :type, :string      # Type: dxa (twips)

      xml do
        # This is a helper class, child elements define root
        namespace Ooxml::Namespaces::WordProcessingML
        map_attribute "w", to: :w
        map_attribute "type", to: :type, render_nil: false
      end
    end
  end
end
