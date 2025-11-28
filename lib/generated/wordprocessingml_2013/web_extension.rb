# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Web extension reference for Office Add-ins
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:webExtension>
      class WebExtension < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            root 'webExtension'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
