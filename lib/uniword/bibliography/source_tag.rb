# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Bibliography
    # Unique identifier tag for source
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:tag>
    class SourceTag < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "tag"
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute "val", to: :val
      end
    end
  end
end
