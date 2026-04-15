# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Hide end-of-cell mark
    #
    # Represents w:hideMark element in table cell properties.
    # When present, hides the cell mark glyph.
    #
    # Element: <w:hideMark/>
    class HideMark < Lutaml::Model::Serializable
      xml do
        element "hideMark"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
