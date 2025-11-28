# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Table revision save ID for change tracking
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:tblRsid>
      class TableRsid < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'tblRsid'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
