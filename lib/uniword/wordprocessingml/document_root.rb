# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Root element of a WordprocessingML document
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:document>
    class DocumentRoot < Lutaml::Model::Serializable
      attribute :body, Body

      xml do
        element 'document'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'body', to: :body
      end
    end
  end
end
