# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2016
    # Individual extension element
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:ext>
    class Extension < Lutaml::Model::Serializable
      attribute :uri, String
      attribute :content, String

      xml do
        element 'ext'
        namespace Uniword::Ooxml::Namespaces::Word2015
        mixed_content

        map_attribute 'uri', to: :uri
        map_element 'content', to: :content, render_nil: false
      end
    end
  end
end
