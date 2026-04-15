# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Soft hyphen character
    #
    # Element: <w:softHyphen>
    class SoftHyphen < Lutaml::Model::Serializable
      xml do
        element "softHyphen"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
