# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Auto filter settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:autoFilter>
      class AutoFilter < Lutaml::Model::Serializable
          attribute :ref, String
          attribute :filter_columns, String, collection: true, default: -> { [] }

          xml do
            root 'autoFilter'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :ref
            map_element 'filterColumn', to: :filter_columns, render_nil: false
          end
      end
    end
  end
end
