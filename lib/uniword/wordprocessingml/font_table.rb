# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Font table (word/fontTable.xml)
    #
    # Contains font definitions used in the document
    class FontTable < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :mc_ignorable, Uniword::Ooxml::Types::McIgnorable
      attribute :fonts, Font, collection: true, initialize_empty: true

      xml do
        element 'fonts'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Force mc: namespace declaration on root element
        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility, declare: :always },
        ]

        map_attribute 'Ignorable', to: :mc_ignorable, render_nil: false
        map_element 'font', to: :fonts, render_nil: false
      end
    end
  end
end
