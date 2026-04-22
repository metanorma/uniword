# frozen_string_literal: true

require "lutaml/model"

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
        element "fonts"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Force mc: namespace declaration on root element
        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Relationships, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2012, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018Cex, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2016Cid, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2023Du, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2020SdtDataHash, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2024SdtFormatLock, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2015Symex, declare: :always }
        ]

        map_attribute "Ignorable", to: :mc_ignorable, render_nil: false
        map_element "font", to: :fonts, render_nil: false
      end
    end
  end
end
