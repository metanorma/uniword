# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Globally unique identifier for bibliography source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:guid>
      class Guid < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'guid'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
