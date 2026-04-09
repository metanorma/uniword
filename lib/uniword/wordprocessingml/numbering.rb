# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Numbering definitions
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:numbering>
    class Numbering < Lutaml::Model::Serializable
      attribute :abstractNums, AbstractNum, collection: true, initialize_empty: true
      attribute :nums, Num, collection: true, initialize_empty: true

      xml do
        element 'numbering'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'abstractNum', to: :abstractNums, render_nil: false
        map_element 'num', to: :nums, render_nil: false
      end
    end
  end
end
