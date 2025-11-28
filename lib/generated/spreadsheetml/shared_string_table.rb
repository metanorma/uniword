# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Shared string table
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sst>
      class SharedStringTable < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :unique_count, Integer
          attribute :si_entries, StringItem, collection: true, default: -> { [] }

          xml do
            root 'sst'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_attribute 'true', to: :unique_count
            map_element 'si', to: :si_entries, render_nil: false
          end
      end
    end
  end
end
