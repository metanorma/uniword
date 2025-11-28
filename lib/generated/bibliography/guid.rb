# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Globally unique identifier for bibliography source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:guid>
      class Guid < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'guid'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
