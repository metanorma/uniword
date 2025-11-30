# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Issue number for periodicals
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:issue>
      class Issue < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'issue'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
