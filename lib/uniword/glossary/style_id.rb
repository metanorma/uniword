# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Glossary
    # Style identifier reference for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:style_id>
    class StyleId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        root "style"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end
    end
  end
end
