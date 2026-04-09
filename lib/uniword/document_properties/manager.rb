# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Manager name
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:Manager>
    class Manager < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element 'Manager'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
