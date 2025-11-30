# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Relationship data table for diagrams
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:relationtable>
    class VmlRelationTable < Lutaml::Model::Serializable
      attribute :ext, String
      attribute :data, String

      xml do
        element 'relationtable'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'ext', to: :ext
        map_element '', to: :data, render_nil: false
      end
    end
  end
end
