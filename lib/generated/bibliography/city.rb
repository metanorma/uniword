# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # City of publication
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:city>
      class City < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'city'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
