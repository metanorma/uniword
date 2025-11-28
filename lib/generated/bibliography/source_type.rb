# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Type of bibliography source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:source_type>
      class SourceType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'source_type'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
