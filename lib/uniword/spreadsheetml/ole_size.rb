# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # OLE object size specification
    #
    # Element: <oleSize>
    class OleSize < Lutaml::Model::Serializable
      attribute :ref, :string

      xml do
        element "oleSize"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "ref", to: :ref
      end
    end
  end
end
