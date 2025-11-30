# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Title of the bibliography source
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:title>
      class Title < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'title'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
