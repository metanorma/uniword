# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Mirror margins for book layout (empty marker)
    #
    # Element: <w:mirrorMargins>
    class MirrorMargins < Lutaml::Model::Serializable
      xml do
        element "mirrorMargins"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
