# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2016
    # Cell revision save ID for change tracking
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:cellRsid>
    class CellRsid < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "cellRsid"
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute "val", to: :val
      end
    end
  end
end
