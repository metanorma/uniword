# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2013
      # Individual item in repeating section
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:repeatingSectionItem>
      class RepeatingSectionItem < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            element 'repeatingSectionItem'
            namespace Uniword::Ooxml::Namespaces::Word2012

            map_attribute 'id', to: :id
          end
      end
    end
end
