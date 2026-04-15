# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Merged cell range
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:mergeCell>
    class MergeCell < Lutaml::Model::Serializable
      attribute :ref, :string

      xml do
        element "mergeCell"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "ref", to: :ref
      end
    end
  end
end
