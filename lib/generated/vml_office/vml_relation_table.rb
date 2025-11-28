# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Relationship data table for diagrams
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:relationtable>
      class VmlRelationTable < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :data, String

          xml do
            root 'relationtable'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :ext
            map_element '', to: :data, render_nil: false
          end
      end
    end
  end
end
