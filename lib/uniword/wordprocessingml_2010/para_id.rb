# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Paragraph ID for change tracking
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:paraId>
    class ParaId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "paraId"
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute "val", to: :val
      end
    end
  end
end
