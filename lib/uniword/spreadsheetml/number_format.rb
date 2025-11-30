# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Number format definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:numFmt>
    class NumberFormat < Lutaml::Model::Serializable
      attribute :num_fmt_id, Integer
      attribute :format_code, String

      xml do
        element 'numFmt'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'num-fmt-id', to: :num_fmt_id
        map_attribute 'format-code', to: :format_code
      end
    end
  end
end
