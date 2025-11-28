# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Linked web extension
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:webExtensionLinked>
      class WebExtensionLinked < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            root 'webExtensionLinked'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
