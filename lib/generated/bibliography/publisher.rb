# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Publisher name
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:publisher>
      class Publisher < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'publisher'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
