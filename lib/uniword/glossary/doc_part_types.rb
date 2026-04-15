# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Glossary
    # Type definitions for a document part
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part_types>
    class DocPartTypes < Lutaml::Model::Serializable
      attribute :type, DocPartType, collection: true, initialize_empty: true
      attribute :all, :boolean

      xml do
        root "types"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "type", to: :type, render_nil: false
        map_attribute "all", to: :all
      end
    end
  end
end
