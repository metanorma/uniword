# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Semi-hidden style marker
    #
    # Element: <w:semiHidden>
    class SemiHidden < Lutaml::Model::Serializable
      xml do
        element 'semiHidden'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Unhide when used marker
    #
    # Element: <w:unhideWhenUsed>
    class UnhideWhenUsed < Lutaml::Model::Serializable
      xml do
        element 'unhideWhenUsed'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
