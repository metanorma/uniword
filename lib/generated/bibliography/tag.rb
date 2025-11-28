# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Unique identifier tag for source citations
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:tag>
      class Tag < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'tag'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
