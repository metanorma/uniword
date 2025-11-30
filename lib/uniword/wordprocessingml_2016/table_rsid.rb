# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2016
    # Table revision save ID for change tracking
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:tblRsid>
    class TableRsid < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'tblRsid'
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute 'val', to: :val
      end
    end
  end
end
