# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Edition information
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:edition>
      class Edition < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'edition'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
