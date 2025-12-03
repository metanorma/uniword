# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML text box container
      # Contains WordprocessingML TextBoxContent
      #
      # Element: <v:textbox>
      class Textbox < Lutaml::Model::Serializable
        # PATTERN 0: Attributes FIRST
        attribute :style, :string
        attribute :inset, :string
        attribute :content, Uniword::Wordprocessingml::TextBoxContent

        xml do
          root 'textbox'
          namespace Uniword::Ooxml::Namespaces::Vml
          mixed_content

          map_attribute 'style', to: :style, render_nil: false
          map_attribute 'inset', to: :inset, render_nil: false
          map_element 'txbxContent', to: :content, render_nil: false
        end
      end
    end
  end
end
