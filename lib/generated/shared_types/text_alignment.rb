# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Text alignment enumeration
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:text_alignment>
      class TextAlignment < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'text_alignment'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
