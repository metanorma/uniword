# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Last name of an author
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:last>
      class Last < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'last'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
