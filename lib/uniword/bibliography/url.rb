# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Web URL for online sources
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:url>
      class Url < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'url'
            namespace Uniword::Ooxml::Namespaces::Bibliography

            map_attribute 'val', to: :val
          end
      end
    end
end
