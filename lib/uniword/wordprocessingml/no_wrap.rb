# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # No-wrap marker for cell-level text wrapping prevention
    # XML: <w:noWrap/>
    class NoWrap < Lutaml::Model::Serializable
      xml do
        element "noWrap"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
