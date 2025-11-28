# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Title of the bibliography source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:title>
      class Title < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'title'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
