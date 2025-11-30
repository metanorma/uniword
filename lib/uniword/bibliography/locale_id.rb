# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Locale identifier for source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:lcid>
      class LocaleId < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'lcid'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
