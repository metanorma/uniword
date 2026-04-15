# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table style reference
    #
    # Element: <w:tblStyle>
    class TableStyle < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        root "tblStyle"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
