# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Automatic footnote reference mark
    #
    # Placed inside a footnote's paragraph to render the footnote number.
    # Element: <w:footnoteRef>
    #
    # ISO/IEC 29500-1:2016 - Section 17.11.11
    class FootnoteRef < Lutaml::Model::Serializable
      xml do
        element "footnoteRef"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
