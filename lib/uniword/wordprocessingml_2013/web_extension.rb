# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Web extension reference for Office Add-ins
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:webExtension>
    class WebExtension < Lutaml::Model::Serializable
      attribute :id, String

      xml do
        element 'webExtension'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'id', to: :id
      end
    end
  end
end
