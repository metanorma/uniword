# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Do not include subdocs in statistics (empty marker)
    #
    # Element: <w:doNotIncludeSubdocsInStats>
    class DoNotIncludeSubdocsInStats < Lutaml::Model::Serializable
      xml do
        element "doNotIncludeSubdocsInStats"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
