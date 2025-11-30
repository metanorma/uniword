# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2016
      # Separator extension properties
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:sepx>
      class SeparatorExtension < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            element 'sepx'
            namespace Uniword::Ooxml::Namespaces::Word2015

            map_attribute 'val', to: :val
          end
      end
    end
end
