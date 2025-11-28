# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # External references collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:externalReferences>
      class ExternalReferences < Lutaml::Model::Serializable
          attribute :refs, String, collection: true, default: -> { [] }

          xml do
            root 'externalReferences'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'externalReference', to: :refs, render_nil: false
          end
      end
    end
  end
end
