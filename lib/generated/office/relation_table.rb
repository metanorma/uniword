# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Relationship table
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:relationtable>
      class RelationTable < Lutaml::Model::Serializable
          attribute :data, String

          xml do
            root 'relationtable'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_element '', to: :data, render_nil: false
          end
      end
    end
  end
end
