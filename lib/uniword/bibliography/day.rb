# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Publication day
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:day>
    class Day < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'day'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
