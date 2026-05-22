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
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingCanvas,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx1, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx2, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx3, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx4, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx5, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx6, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx7, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx8, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::InkDrawing,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Model3D, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Office, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::OfficeExtensionList,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Relationships,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::MathML, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Vml, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010Drawing,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordProcessingDrawing,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::VmlWord, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2012, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018Cex,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2016Cid,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2023Du,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2020SdtDataHash,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2024SdtFormatLock,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2015Symex,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingGroup,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingInk,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordNumberingEquations,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingShape,
            declare: :always },
        ]

        map_element "abstractNum", to: :abstractNums, render_nil: false
        map_element "num", to: :nums, render_nil: false
      end
    end
  end
end
