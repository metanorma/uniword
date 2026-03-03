# frozen_string_literal: true

require 'lutaml/model'
require_relative 'sdt/id'
require_relative 'sdt/alias'
require_relative 'sdt/tag'
require_relative 'sdt/text'
require_relative 'sdt/showing_placeholder_header'
require_relative 'sdt/appearance'
require_relative 'sdt/placeholder'
require_relative 'sdt/data_binding'
require_relative 'sdt/bibliography'
require_relative 'sdt/temporary'
require_relative 'sdt/doc_part_obj'
require_relative 'sdt/date'
require_relative 'sdt/run_properties'

module Uniword
  # Container for Structured Document Tag Properties
  # Integrates all SDT-related properties in a single model
  class StructuredDocumentTagProperties < Lutaml::Model::Serializable
    # Pattern 0: ATTRIBUTES FIRST (CRITICAL!)
    attribute :id, Sdt::Id
    attribute :alias_name, Sdt::Alias
    attribute :tag, Sdt::Tag
    attribute :text, Sdt::Text
    attribute :showing_placeholder_header, Sdt::ShowingPlaceholderHeader
    attribute :appearance, Sdt::Appearance
    attribute :placeholder, Sdt::Placeholder
    attribute :data_binding, Sdt::DataBinding
    attribute :bibliography, Sdt::Bibliography
    attribute :temporary, Sdt::Temporary
    attribute :doc_part_obj, Sdt::DocPartObj
    attribute :date, Sdt::Date
    attribute :run_properties, Sdt::RunProperties

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
