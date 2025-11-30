# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # City of publication
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:city>
      class City < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'city'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
