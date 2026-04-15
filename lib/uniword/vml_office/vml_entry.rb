# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Entry point for VML diagram
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:entry>
    class VmlEntry < Lutaml::Model::Serializable
      attribute :new, :string
      attribute :old, :string

      xml do
        element "entry"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "new", to: :new
        map_attribute "old", to: :old
      end
    end
  end
end
