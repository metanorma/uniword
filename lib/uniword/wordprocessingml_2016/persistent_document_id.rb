# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2016
    # Persistent document identifier for tracking across sessions
    #
    # Generated from OOXML schema: wordprocessingml_2016.yml
    # Element: <w16:persistentDocumentId>
    class PersistentDocumentId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'persistentDocumentId'
        namespace Uniword::Ooxml::Namespaces::Word2015

        map_attribute 'val', to: :val
      end
    end
  end
end
