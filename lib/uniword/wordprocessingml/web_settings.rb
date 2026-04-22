# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Optimize for browser marker element
    # Presence = true, Absence = false
    class OptimizeForBrowser < Lutaml::Model::Serializable
      xml do
        element "optimizeForBrowser"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Allow PNG marker element
    # Presence = true, Absence = false
    class AllowPng < Lutaml::Model::Serializable
      xml do
        element "allowPNG"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Web settings (word/webSettings.xml)
    #
    # Contains settings related to web publishing
    class WebSettings < Lutaml::Model::Serializable
      attribute :mc_ignorable, Ooxml::Types::McIgnorable
      attribute :optimize_for_browser, OptimizeForBrowser
      attribute :allow_png, AllowPng

      xml do
        element "webSettings"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

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
        map_element "optimizeForBrowser", to: :optimize_for_browser, render_nil: false
        map_element "allowPNG", to: :allow_png, render_nil: false
      end
    end
  end
end
