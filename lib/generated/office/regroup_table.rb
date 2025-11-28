# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Regroup table
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:regrouptable>
      class RegroupTable < Lutaml::Model::Serializable
          attribute :data, String

          xml do
            root 'regrouptable'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_element '', to: :data, render_nil: false
          end
      end
    end
  end
end
