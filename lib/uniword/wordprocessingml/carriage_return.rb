# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Carriage return
    #
    # Element: <w:cr>
    class CarriageReturn < Lutaml::Model::Serializable
      xml do
        element 'cr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
