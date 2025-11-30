# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Document security level (0-8)
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:DocSecurity>
    class DocSecurity < Lutaml::Model::Serializable
      attribute :content, String

      xml do
        element 'DocSecurity'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
