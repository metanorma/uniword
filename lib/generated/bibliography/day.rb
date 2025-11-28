# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Publication day
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:day>
      class Day < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'day'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
