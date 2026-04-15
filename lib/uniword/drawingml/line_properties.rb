# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Line properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:ln>
    class LineProperties < Lutaml::Model::Serializable
      attribute :w, :integer
      attribute :cap, :string
      attribute :cmpd, :string
      attribute :algn, :string
      attribute :solid_fill, SolidFill
      attribute :grad_fill, GradientFill
      attribute :prst_dash, PresetDash
      attribute :miter, LineJoinMiter

      xml do
        element "ln"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "w", to: :w, render_nil: false
        map_attribute "cap", to: :cap, render_nil: false
        map_attribute "cmpd", to: :cmpd, render_nil: false
        map_attribute "algn", to: :algn, render_nil: false
        map_element "solidFill", to: :solid_fill, render_nil: false
        map_element "gradFill", to: :grad_fill, render_nil: false
        map_element "prstDash", to: :prst_dash, render_nil: false
        map_element "miter", to: :miter, render_nil: false
      end
    end
  end
end
