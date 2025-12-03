# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Top bevel
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:bevelT>
    class BevelTop < Lutaml::Model::Serializable
      attribute :w, :integer
      attribute :h, :integer
      attribute :prst, :string

      xml do
        element 'bevelT'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'w', to: :w, render_nil: false
        map_attribute 'h', to: :h, render_nil: false
        map_attribute 'prst', to: :prst, render_nil: false
      end
    end
  end
end