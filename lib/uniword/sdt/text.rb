# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Text control flag for Structured Document Tag (empty element)
    # Reference XML: <w:text/>
    class Text < Lutaml::Model::Serializable
      xml do
        element 'text'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end