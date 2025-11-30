# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Publication month
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:month>
    class Month < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'month'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
