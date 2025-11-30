# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module WpDrawing
      # Anchor object for positioned drawing object
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:anchor>
      class Anchor < Lutaml::Model::Serializable
          attribute :dist_t, Integer
          attribute :dist_b, Integer
          attribute :dist_l, Integer
          attribute :dist_r, Integer
          attribute :simple_pos, String
          attribute :relative_height, Integer
          attribute :behind_doc, String
          attribute :locked, String
          attribute :layout_in_cell, String
          attribute :allow_overlap, String
          attribute :hidden, String
          attribute :extent, String
          attribute :effect_extent, String
          attribute :wrap_square, String
          attribute :wrap_tight, String
          attribute :wrap_through, String
          attribute :wrap_top_and_bottom, String
          attribute :wrap_none, String
          attribute :doc_pr, String
          attribute :c_nv_graphic_frame_pr, String
          attribute :position_h, String
          attribute :position_v, String

          xml do
            element 'anchor'
            namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
            mixed_content

            map_attribute 'dist-t', to: :dist_t
            map_attribute 'dist-b', to: :dist_b
            map_attribute 'dist-l', to: :dist_l
            map_attribute 'dist-r', to: :dist_r
            map_element 'simplePos', to: :simple_pos, render_nil: false
            map_attribute 'relative-height', to: :relative_height
            map_attribute 'behind-doc', to: :behind_doc
            map_attribute 'locked', to: :locked
            map_attribute 'layout-in-cell', to: :layout_in_cell
            map_attribute 'allow-overlap', to: :allow_overlap
            map_attribute 'hidden', to: :hidden
            map_element '', to: :extent, render_nil: false
            map_element 'effectExtent', to: :effect_extent, render_nil: false
            map_element 'wrapSquare', to: :wrap_square, render_nil: false
            map_element 'wrapTight', to: :wrap_tight, render_nil: false
            map_element 'wrapThrough', to: :wrap_through, render_nil: false
            map_element 'wrapTopAndBottom', to: :wrap_top_and_bottom, render_nil: false
            map_element 'wrapNone', to: :wrap_none, render_nil: false
            map_element 'docPr', to: :doc_pr, render_nil: false
            map_element 'cNvGraphicFramePr', to: :c_nv_graphic_frame_pr, render_nil: false
            map_element 'positionH', to: :position_h, render_nil: false
            map_element 'positionV', to: :position_v, render_nil: false
          end
      end
    end
end
