# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Glossary
    # Behavioral properties for a document part
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part_behaviors>
    class DocPartBehaviors < Lutaml::Model::Serializable
      attribute :behavior, DocPartBehavior, collection: true, initialize_empty: true

      xml do
        root "behaviors"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "behavior", to: :behavior, render_nil: false
      end
    end
  end
end
