# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Defined as a stub first to break the WebDiv ↔ DivsChild mutual recursion.
    # The :div attribute is added after WebDiv is defined.
    class DivsChild < Lutaml::Model::Serializable
      xml do
        element "divsChild"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
      end
    end
  end
end
