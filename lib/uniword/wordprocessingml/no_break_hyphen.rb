# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Non-breaking hyphen character
    #
    # Element: <w:noBreakHyphen>
    class NoBreakHyphen < Lutaml::Model::Serializable
      xml do
        element "noBreakHyphen"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
