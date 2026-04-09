# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Type of bibliography source
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:source_type>
    class SourceType < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'source_type'
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute 'val', to: :val
      end
    end
  end
end
