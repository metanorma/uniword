# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Container for Structured Document Tag Properties
    # Integrates all SDT-related properties in a single model
    # XML Namespace: w: (WordProcessingML)
    #
    # NOTE: Uses StructuredDocumentTag::* references to access nested property classes.
    class StructuredDocumentTagProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST (CRITICAL!)
      attribute :id, StructuredDocumentTag::Id
      attribute :alias_name, StructuredDocumentTag::Alias
      attribute :tag, StructuredDocumentTag::Tag
      attribute :text, StructuredDocumentTag::Text
      attribute :showing_placeholder_header, StructuredDocumentTag::ShowingPlaceholderHeader
      attribute :appearance, StructuredDocumentTag::Appearance
      attribute :placeholder, StructuredDocumentTag::Placeholder
      attribute :data_binding, StructuredDocumentTag::DataBinding
      attribute :bibliography, StructuredDocumentTag::Bibliography
      attribute :temporary, StructuredDocumentTag::Temporary
      attribute :doc_part_obj, StructuredDocumentTag::DocPartObj
      attribute :date, StructuredDocumentTag::Date
      attribute :run_properties, StructuredDocumentTag::RunProperties

      xml do
        element 'sdtPr'
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        namespace_scope [
          { namespace: Ooxml::Namespaces::Word2012, declare: :auto },
        ]

        map_element 'id', to: :id, render_nil: false
        map_element 'alias', to: :alias_name, render_nil: false
        map_element 'tag', to: :tag, render_nil: false
        map_element 'text', to: :text, render_nil: false
        map_element 'showingPlcHdr', to: :showing_placeholder_header, render_nil: false
        map_element 'appearance', to: :appearance, render_nil: false
        map_element 'placeholder', to: :placeholder, render_nil: false
        map_element 'dataBinding', to: :data_binding, render_nil: false
        map_element 'bibliography', to: :bibliography, render_nil: false
        map_element 'temporary', to: :temporary, render_nil: false
        map_element 'docPartObj', to: :doc_part_obj, render_nil: false
        map_element 'date', to: :date, render_nil: false
        map_element 'rPr', to: :run_properties, render_nil: false
      end
    end
  end
end
