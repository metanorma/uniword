# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Extension element for custom or future features
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:ext>
      class Extension < Lutaml::Model::Serializable
          attribute :uri, :string

          xml do
            root 'ext'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'uri', to: :uri
          end
      end
    end
  end
end
