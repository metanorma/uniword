# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Publication year
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:year>
      class Year < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'year'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
