# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Inline drawing object
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:inline>
    class Inline < Lutaml::Model::Serializable
      attribute :dist_t, :integer
      attribute :dist_b, :integer
      attribute :dist_l, :integer
      attribute :dist_r, :integer
      attribute :extent, :string
      attribute :effect_extent, :string
      attribute :doc_pr, :string
      attribute :c_nv_graphic_frame_pr, :string

      xml do
        element 'inline'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'dist-t', to: :dist_t
        map_attribute 'dist-b', to: :dist_b
        map_attribute 'dist-l', to: :dist_l
        map_attribute 'dist-r', to: :dist_r
        map_element '', to: :extent, render_nil: false
        map_element 'effectExtent', to: :effect_extent, render_nil: false
        map_element 'docPr', to: :doc_pr, render_nil: false
        map_element 'cNvGraphicFramePr', to: :c_nv_graphic_frame_pr, render_nil: false
      end
    end
  end
end
