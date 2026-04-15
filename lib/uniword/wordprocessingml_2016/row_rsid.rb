# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2016
    # Row revision save ID for change tracking
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:rowRsid>
    class RowRsid < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "rowRsid"
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute "val", to: :val
      end
    end
  end
end
