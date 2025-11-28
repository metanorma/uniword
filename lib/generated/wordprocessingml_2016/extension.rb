# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Individual extension element
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:ext>
      class Extension < Lutaml::Model::Serializable
          attribute :uri, String
          attribute :content, String

          xml do
            root 'ext'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'
            mixed_content

            map_attribute 'true', to: :uri
            map_element 'content', to: :content, render_nil: false
          end
      end
    end
  end
end
