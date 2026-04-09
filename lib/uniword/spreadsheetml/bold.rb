# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Bold formatting
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:b>
    class Bold < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'b'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'val', to: :val
      end
    end
  end
end
