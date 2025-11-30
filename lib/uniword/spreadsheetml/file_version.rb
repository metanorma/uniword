# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # File version information
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:fileVersion>
    class FileVersion < Lutaml::Model::Serializable
      attribute :app_name, String
      attribute :last_edited, String

      xml do
        element 'fileVersion'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'app-name', to: :app_name
        map_attribute 'last-edited', to: :last_edited
      end
    end
  end
end
