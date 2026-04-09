# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Linked web extension
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:webExtensionLinked>
    class WebExtensionLinked < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element 'webExtensionLinked'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'id', to: :id
      end
    end
  end
end
