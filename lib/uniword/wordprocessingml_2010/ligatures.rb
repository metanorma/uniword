# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Ligature settings for advanced typography
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:ligatures>
    class Ligatures < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'ligatures'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'val', to: :val
      end
    end
  end
end
