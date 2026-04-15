# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Checkbox control
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:checkbox>
    class Checkbox < Lutaml::Model::Serializable
      attribute :checked, :string
      attribute :value, :string

      xml do
        element "checkbox"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "checked", to: :checked
        map_attribute "value", to: :value
      end
    end
  end
end
