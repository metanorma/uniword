# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Publisher name
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:publisher>
    class Publisher < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'publisher'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
