# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # File sharing settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:fileSharing>
      class FileSharing < Lutaml::Model::Serializable
          attribute :read_only_recommended, String

          xml do
            root 'fileSharing'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :read_only_recommended
          end
      end
    end
  end
end
