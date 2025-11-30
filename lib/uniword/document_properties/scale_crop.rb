# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Scale crop setting for thumbnails
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:ScaleCrop>
    class ScaleCrop < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element 'ScaleCrop'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
