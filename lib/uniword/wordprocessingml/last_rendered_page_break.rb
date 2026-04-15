# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Last rendered page break (rendering hint element)
    # Reference XML: <w:lastRenderedPageBreak/>
    class LastRenderedPageBreak < Lutaml::Model::Serializable
      xml do
        element "lastRenderedPageBreak"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
