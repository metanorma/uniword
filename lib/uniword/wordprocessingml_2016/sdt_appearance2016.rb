# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2016
    # Enhanced SDT appearance for accessibility
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:sdtAppearance>
    class SdtAppearance2016 < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "sdtAppearance"
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute "val", to: :val
      end
    end
  end
end
