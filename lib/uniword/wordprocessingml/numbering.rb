# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Numbering definitions
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:numbering>
    class Numbering < Lutaml::Model::Serializable
      attribute :abstractNums, AbstractNum, collection: true,
                                            initialize_empty: true
      attribute :nums, Num, collection: true, initialize_empty: true

      xml do
        element "numbering"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Force namespace declarations on root for mc:Ignorable prefixes
        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2012, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2015Symex,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2016Cid,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018Cex,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2020SdtDataHash,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2024SdtFormatLock,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2023Du,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010Drawing,
            declare: :always },
        ]

        map_element "abstractNum", to: :abstractNums, render_nil: false
        map_element "num", to: :nums, render_nil: false
      end
    end
  end
end
