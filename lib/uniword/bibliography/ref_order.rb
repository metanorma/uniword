# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Bibliography
    # Reference order in bibliography
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:ref_order>
    class RefOrder < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "ref_order"
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute "val", to: :val
      end
    end
  end
end
