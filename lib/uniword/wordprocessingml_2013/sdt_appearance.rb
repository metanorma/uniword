# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # SDT appearance settings for Word 2013+
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:appearance>
    class SdtAppearance < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'appearance'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'val', to: :val
      end
    end
  end
end
