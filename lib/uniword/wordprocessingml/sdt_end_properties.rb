# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Structured document tag end properties (optional formatting)
    # Reference XML: <w:sdtEndPr/>
    class SdtEndProperties < Lutaml::Model::Serializable
      xml do
        element 'sdtEndPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
