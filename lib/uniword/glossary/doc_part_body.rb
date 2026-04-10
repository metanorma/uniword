# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Body content of a document part (building block content)
    # Contains WordprocessingML elements like paragraphs, tables, and SDTs
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <w:docPartBody>
    class DocPartBody < Lutaml::Model::Serializable
      attribute :paragraphs, Uniword::Wordprocessingml::Paragraph, collection: true,
                                                                   initialize_empty: true
      attribute :tables, Uniword::Wordprocessingml::Table, collection: true, initialize_empty: true
      attribute :sdts, Uniword::Wordprocessingml::StructuredDocumentTag, collection: true,
                                                                         initialize_empty: true

      xml do
        root 'docPartBody'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'p', to: :paragraphs, render_nil: false
        map_element 'tbl', to: :tables, render_nil: false
        map_element 'sdt', to: :sdts, render_nil: false
      end
    end
  end
end
