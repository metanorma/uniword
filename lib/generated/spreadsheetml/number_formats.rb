# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Number formats collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:numFmts>
      class NumberFormats < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :formats, NumberFormat, collection: true, default: -> { [] }

          xml do
            root 'numFmts'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'numFmt', to: :formats, render_nil: false
          end
      end
    end
  end
end
