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
            root 'textbox'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :style
            map_attribute 'true', to: :inset
            map_element '', to: :content, render_nil: false
          end
      end
    end
  end
end
