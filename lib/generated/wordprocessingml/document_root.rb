# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Root element of a WordprocessingML document
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:document>
      class DocumentRoot < Lutaml::Model::Serializable
          attribute :body, Body

          xml do
            root 'document'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'body', to: :body
          end
      end
    end
  end
end
