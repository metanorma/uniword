# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML text box container
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:textbox>
      class Textbox < Lutaml::Model::Serializable
        attribute :style, String
        attribute :inset, String
        attribute :content, String

        xml do
          element 'textbox'
          namespace Uniword::Ooxml::Namespaces::Vml

          map_attribute 'style', to: :style
          map_attribute 'inset', to: :inset
          map_element '', to: :content, render_nil: false
        end
      end
    end
  end
end
