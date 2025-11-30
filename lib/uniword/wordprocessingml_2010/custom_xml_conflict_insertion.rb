# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Custom XML conflict insertion
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:customXmlConflictIns>
    class CustomXmlConflictInsertion < Lutaml::Model::Serializable
      attribute :id, String
      attribute :uri, String

      xml do
        element 'customXmlConflictIns'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'id', to: :id
        map_attribute 'uri', to: :uri
      end
    end
  end
end
