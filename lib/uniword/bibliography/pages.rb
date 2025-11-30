# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Page range for the source
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:pages>
    class Pages < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'pages'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
