# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # External references collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:externalReferences>
    class ExternalReferences < Lutaml::Model::Serializable
      attribute :refs, :string, collection: true, initialize_empty: true

      xml do
        element 'externalReferences'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'externalReference', to: :refs, render_nil: false
      end
    end
  end
end
