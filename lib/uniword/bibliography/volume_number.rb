# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Bibliography
    # Volume number for periodicals
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:volume_number>
    class VolumeNumber < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "volume_number"
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute "val", to: :val
      end
    end
  end
end
