# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Web video embedding properties
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:webVideoProperty>
      class WebVideoProperty < Lutaml::Model::Serializable
          attribute :embed_code, String
          attribute :video_url, String

          xml do
            root 'webVideoProperty'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'

            map_attribute 'true', to: :embed_code
            map_attribute 'true', to: :video_url
          end
      end
    end
  end
end
