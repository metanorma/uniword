# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Volume number for periodicals
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:volume_number>
      class VolumeNumber < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'volume_number'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
