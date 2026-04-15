# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Bibliography
    # Last name / family name / surname
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:last>
    class LastName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "last"
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute "val", to: :val
      end
    end
  end
end
