# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2016
      # Web video embedding properties
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:webVideoProperty>
      class WebVideoProperty < Lutaml::Model::Serializable
          attribute :embed_code, String
          attribute :video_url, String

          xml do
            element 'webVideoProperty'
            namespace Uniword::Ooxml::Namespaces::Word2015

            map_attribute 'embed-code', to: :embed_code
            map_attribute 'video-url', to: :video_url
          end
      end
    end
end
