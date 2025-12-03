# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Inline drawing object
    # Flows with text, no positioning
    class Inline < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :dist_t, :integer  # Distance from text - top
      attribute :dist_b, :integer  # Distance from text - bottom
      attribute :dist_l, :integer  # Distance from text - left
      attribute :dist_r, :integer  # Distance from text - right
      attribute :extent, Extent
      attribute :doc_properties, DocProperties
      attribute :non_visual_props, NonVisualDrawingProps
      attribute :graphic, Drawingml::Graphic

      xml do
        root 'inline'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'distT', to: :dist_t, render_nil: false
        map_attribute 'distB', to: :dist_b, render_nil: false
        map_attribute 'distL', to: :dist_l, render_nil: false
        map_attribute 'distR', to: :dist_r, render_nil: false
        map_element 'extent', to: :extent, render_nil: false
        map_element 'docPr', to: :doc_properties, render_nil: false
        map_element 'cNvGraphicFramePr', to: :non_visual_props, render_nil: false
        map_element 'graphic', to: :graphic, render_nil: false
      end
    end
  end
end