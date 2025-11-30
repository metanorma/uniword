# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Embedded font reference
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:embedded_font>
      class EmbeddedFont < Lutaml::Model::Serializable
          attribute :typeface, :string
          attribute :charset, :string

          xml do
            element 'embedded_font'
            namespace Uniword::Ooxml::Namespaces::PresentationalML

            map_attribute 'typeface', to: :typeface
            map_attribute 'charset', to: :charset
          end
      end
    end
end
