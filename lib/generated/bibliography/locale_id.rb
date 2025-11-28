# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # Locale identifier for source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:lcid>
      class LocaleId < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'lcid'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
