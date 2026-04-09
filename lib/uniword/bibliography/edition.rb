# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Edition information
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:edition>
    class Edition < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'edition'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
