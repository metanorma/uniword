# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Position tab element
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:ptab>
    class PositionTab < Lutaml::Model::Serializable
      attribute :relative_to, :string
      attribute :alignment, :string
      attribute :leader, :string

      xml do
        element "ptab"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "relativeTo", to: :relative_to, render_nil: false
        map_attribute "alignment", to: :alignment, render_nil: false
        map_attribute "leader", to: :leader, render_nil: false
      end
    end
  end
end
