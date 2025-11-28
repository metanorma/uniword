# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # String value type
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:string>
      class StringType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'string'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
