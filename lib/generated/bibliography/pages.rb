# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Page range for the source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:pages>
      class Pages < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'pages'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
