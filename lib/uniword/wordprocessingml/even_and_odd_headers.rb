# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Even and odd page headers (empty marker)
    #
    # Element: <w:evenAndOddHeaders>
    class EvenAndOddHeaders < Lutaml::Model::Serializable
      xml do
        element "evenAndOddHeaders"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
