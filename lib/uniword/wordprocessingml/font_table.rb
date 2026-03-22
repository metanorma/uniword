# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Font table (word/fontTable.xml)
    #
    # Contains font definitions used in the document
    class FontTable < Lutaml::Model::Serializable
      attribute :fonts, Font, collection: true, initialize_empty: true

      xml do
        element 'fonts'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_element 'font', to: :fonts, render_nil: false
      end
    end
  end
end
