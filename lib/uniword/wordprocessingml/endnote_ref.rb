# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Automatic endnote reference mark
    #
    # Placed inside an endnote's paragraph to render the endnote number.
    # Element: <w:endnoteRef>
    #
    # ISO/IEC 29500-1:2016 - Section 17.11.7
    class EndnoteRef < Lutaml::Model::Serializable
      xml do
        element 'endnoteRef'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
