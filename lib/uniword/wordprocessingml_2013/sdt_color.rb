# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # SDT color settings
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:color>
    class SdtColor < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'color'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
