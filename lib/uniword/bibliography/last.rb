# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Last name of an author
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:last>
    class Last < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'last'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
