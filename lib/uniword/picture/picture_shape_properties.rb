# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Picture
    # Picture shape properties
    #
    # Generated from OOXML schema: picture.yml
    # Element: <pic:spPr>
    class PictureShapeProperties < Lutaml::Model::Serializable
      attribute :xfrm, :string
      attribute :ln, :string

      xml do
        element 'spPr'
        namespace Uniword::Ooxml::Namespaces::Picture
        mixed_content

        map_element 'xfrm', to: :xfrm, render_nil: false
        map_element 'ln', to: :ln, render_nil: false
      end
    end
  end
end
