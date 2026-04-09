# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # First name of an author
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:first>
    class First < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'first'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
