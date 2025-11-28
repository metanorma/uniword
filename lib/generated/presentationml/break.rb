# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Line break within text
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:br>
      class Break < Lutaml::Model::Serializable
          attribute :type, :string

          xml do
            root 'br'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'type', to: :type
          end
      end
    end
  end
end
