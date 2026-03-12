# frozen_string_literal: true

require 'lutaml/model'
# NOTE: Sdt namespace MUST be eager-loaded because we use bare Sdt:: constants
# in attribute definitions. Ruby's autoload doesn't trigger for nested constant
# access like Uniword::Sdt::Id - only for direct access like Uniword::Sdt.
require_relative '../sdt'

module Uniword
  module Wordprocessingml
    # Container for Structured Document Tag Properties
    # Integrates all SDT-related properties in a single model
    # XML Namespace: w: (WordProcessingML)
    #
    # NOTE: Uses Uniword::Sdt::* references to trigger autoload correctly.
    # Bare Sdt::* references don't trigger autoload for nested constants.
    class StructuredDocumentTagProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST (CRITICAL!)
      attribute :id, Uniword::Sdt::Id
      attribute :alias_name, Uniword::Sdt::Alias
      attribute :tag, Uniword::Sdt::Tag
      attribute :text, Uniword::Sdt::Text
      attribute :showing_placeholder_header, Uniword::Sdt::ShowingPlaceholderHeader
      attribute :appearance, Uniword::Sdt::Appearance
      attribute :placeholder, Uniword::Sdt::Placeholder
      attribute :data_binding, Uniword::Sdt::DataBinding
      attribute :bibliography, Uniword::Sdt::Bibliography
      attribute :temporary, Uniword::Sdt::Temporary
      attribute :doc_part_obj, Uniword::Sdt::DocPartObj
      attribute :date, Uniword::Sdt::Date
      attribute :run_properties, Uniword::Sdt::RunProperties

      xml do
        element 'sdtPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

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
