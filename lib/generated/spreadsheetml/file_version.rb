# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # File version information
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:fileVersion>
      class FileVersion < Lutaml::Model::Serializable
          attribute :app_name, String
          attribute :last_edited, String

          xml do
            root 'fileVersion'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :app_name
            map_attribute 'true', to: :last_edited
          end
      end
    end
  end
end
