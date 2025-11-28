# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Number format definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:numFmt>
      class NumberFormat < Lutaml::Model::Serializable
          attribute :num_fmt_id, Integer
          attribute :format_code, String

          xml do
            root 'numFmt'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :num_fmt_id
            map_attribute 'true', to: :format_code
          end
      end
    end
  end
end
