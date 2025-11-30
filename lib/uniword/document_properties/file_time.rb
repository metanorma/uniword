# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # File time value type
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:filetime>
    class FileTime < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element 'filetime'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
