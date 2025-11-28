# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Individual item in repeating section
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:repeatingSectionItem>
      class RepeatingSectionItem < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            root 'repeatingSectionItem'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
