# frozen_string_literal: true

require "lutaml/model"
# StructuredDocumentTag namespace autoloads for nested property classes
# These are SDT property elements that appear within <w:sdtPr>

module Uniword
  module Wordprocessingml
    # Structured document tag (main WordProcessingML namespace)
    # Reference XML: <w:sdt>
    #
    # This class also serves as a namespace for SDT property classes:
    # - StructuredDocumentTag::Id
    # - StructuredDocumentTag::Alias
    # - StructuredDocumentTag::Tag
    # - etc.
    class StructuredDocumentTag < Lutaml::Model::Serializable
      # SDT Property classes (autoloaded)
      autoload :Id, "#{__dir__}/structured_document_tag/id"
      autoload :Alias, "#{__dir__}/structured_document_tag/alias"
      autoload :Tag, "#{__dir__}/structured_document_tag/tag"
      autoload :Text, "#{__dir__}/structured_document_tag/text"
      autoload :ShowingPlaceholderHeader,
               "#{__dir__}/structured_document_tag/showing_placeholder_header"
      autoload :Appearance, "#{__dir__}/structured_document_tag/appearance"
      autoload :Placeholder, "#{__dir__}/structured_document_tag/placeholder"
      autoload :DocPartReference,
               "#{__dir__}/structured_document_tag/placeholder"
      autoload :DataBinding, "#{__dir__}/structured_document_tag/data_binding"
      autoload :Bibliography, "#{__dir__}/structured_document_tag/bibliography"
      autoload :Temporary, "#{__dir__}/structured_document_tag/temporary"
      autoload :DocPartObj, "#{__dir__}/structured_document_tag/doc_part_obj"
      autoload :DocPartGallery,
               "#{__dir__}/structured_document_tag/doc_part_obj"
      autoload :DocPartCategory,
               "#{__dir__}/structured_document_tag/doc_part_obj"
      autoload :DocPartUnique, "#{__dir__}/structured_document_tag/doc_part_obj"
      autoload :Date, "#{__dir__}/structured_document_tag/date"
      autoload :DateFormat, "#{__dir__}/structured_document_tag/date"
      autoload :Lid, "#{__dir__}/structured_document_tag/date"
      autoload :StoreMappedDataAs, "#{__dir__}/structured_document_tag/date"
      autoload :Calendar, "#{__dir__}/structured_document_tag/date"
      autoload :RunProperties,
               "#{__dir__}/structured_document_tag/run_properties"

      # SDT content and end properties classes (autoloaded)
      autoload :Content, "#{__dir__}/structured_document_tag/content"
      autoload :EndProperties,
               "#{__dir__}/structured_document_tag/end_properties"

      # Main SDT attributes
      attribute :properties, StructuredDocumentTagProperties
      attribute :end_properties, EndProperties
      attribute :content, Content

      xml do
        element "sdt"
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "sdtPr", to: :properties, render_nil: false
        map_element "sdtEndPr", to: :end_properties, render_nil: false
        map_element "sdtContent", to: :content, render_nil: false
      end
    end
  end
end
