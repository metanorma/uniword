# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # File sharing settings
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:fileSharing>
    class FileSharing < Lutaml::Model::Serializable
      attribute :read_only_recommended, String

      xml do
        element 'fileSharing'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'read-only-recommended', to: :read_only_recommended
      end
    end
  end
end
