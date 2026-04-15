# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Conflict resolution mode
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:conflictMode>
    class ConflictMode < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "conflictMode"
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute "val", to: :val
      end
    end
  end
end
