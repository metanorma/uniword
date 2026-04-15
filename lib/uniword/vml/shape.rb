# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML shape element
    # Enhanced to support proper textbox and wrap model classes
    #
    # Element: <v:shape>
    class Shape < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :id, :string
      attribute :type, :string
      attribute :style, :string
      attribute :fillcolor, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :path, :string
      attribute :fill, Fill
      attribute :stroke, Stroke
      attribute :textbox, Textbox
      attribute :textpath, TextPath
      attribute :wrap, Wrap
      attribute :imagedata, Imagedata

      # o: namespace attributes
      attribute :o_spid, :string
      attribute :o_allowincell, :string

      # VML attributes
      attribute :stroked, :string
      attribute :filled, :string

      xml do
        root "shape"
        namespace Uniword::Ooxml::Namespaces::Vml
        mixed_content

        # Declare Office namespace at root level so o:spid, o:allowincell work
        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::Office, declare: :always }
        ]

        map_attribute "id", to: :id, render_nil: false
        map_attribute "type", to: :type, render_nil: false
        map_attribute "style", to: :style, render_nil: false
        map_attribute "fillcolor", to: :fillcolor, render_nil: false
        map_attribute "strokecolor", to: :strokecolor, render_nil: false
        map_attribute "strokeweight", to: :strokeweight, render_nil: false
        map_attribute "coordsize", to: :coordsize, render_nil: false
        map_attribute "coordorigin", to: :coordorigin, render_nil: false
        map_attribute "path", to: :path, render_nil: false
        map_element "fill", to: :fill, render_nil: false
        map_element "stroke", to: :stroke, render_nil: false
        map_element "textbox", to: :textbox, render_nil: false
        map_element "textpath", to: :textpath, render_nil: false
        map_element "wrap", to: :wrap, render_nil: false
        map_element "imagedata", to: :imagedata, render_nil: false

        # o: namespace attributes
        map_attribute "spid", to: :o_spid, render_nil: false
        map_attribute "allowincell", to: :o_allowincell, render_nil: false

        # VML attributes
        map_attribute "stroked", to: :stroked, render_nil: false
        map_attribute "filled", to: :filled, render_nil: false
      end
    end
  end
end
