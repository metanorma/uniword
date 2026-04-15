# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Structured document tag content container
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:sdtContent>
    class SdtContent < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "sdtContent"
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_element "content", to: :content, render_nil: false
      end
    end
  end
end
