# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Numbering format
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:numFmt>
    class NumFmt < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'numFmt'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
