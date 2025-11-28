# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Embedded object reference
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:embed>
      class Embed < Lutaml::Model::Serializable
          attribute :r_id, :string

          xml do
            root 'embed'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'id', to: :r_id
          end
      end
    end
  end
end
