# frozen_string_literal: true

# Wordprocessingml2010 namespace module
# This file explicitly autoloads all Wordprocessingml2010 classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# WordprocessingML 2010 Extended namespace
# Namespace: http://schemas.microsoft.com/office/word/2010/wordml
# Prefix: w14:
# Generated classes for Word 2010 features

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Autoload all Wordprocessingml2010 classes (25)
    autoload :Checkbox, "uniword/wordprocessingml_2010/checkbox"
    autoload :CheckedState, "uniword/wordprocessingml_2010/checked_state"
    autoload :ConditionalFormatStyle, "uniword/wordprocessingml_2010/conditional_format_style"
    autoload :ConflictDeletion, "uniword/wordprocessingml_2010/conflict_deletion"
    autoload :ConflictInsertion, "uniword/wordprocessingml_2010/conflict_insertion"
    autoload :ConflictMode, "uniword/wordprocessingml_2010/conflict_mode"
    autoload :CustomXmlConflictInsertion,
             "uniword/wordprocessingml_2010/custom_xml_conflict_insertion"
    autoload :DocId, "uniword/wordprocessingml_2010/doc_id"
    autoload :DocPartGallery, "uniword/wordprocessingml_2010/doc_part_gallery"
    autoload :DocPartObj, "uniword/wordprocessingml_2010/doc_part_obj"
    autoload :EntityPicker, "uniword/wordprocessingml_2010/entity_picker"
    autoload :Ligatures, "uniword/wordprocessingml_2010/ligatures"
    autoload :NumberForm, "uniword/wordprocessingml_2010/number_form"
    autoload :ParaId, "uniword/wordprocessingml_2010/para_id"
    autoload :Props3d, "uniword/wordprocessingml_2010/props3d"
    autoload :SdtContent, "uniword/wordprocessingml_2010/sdt_content"
    autoload :SdtProperties, "uniword/wordprocessingml_2010/sdt_properties"
    autoload :StructuredDocumentTag, "uniword/wordprocessingml_2010/structured_document_tag"
    autoload :TextFill, "uniword/wordprocessingml_2010/text_fill"
    autoload :TextGlow, "uniword/wordprocessingml_2010/text_glow"
    autoload :TextId, "uniword/wordprocessingml_2010/text_id"
    autoload :TextOutline, "uniword/wordprocessingml_2010/text_outline"
    autoload :TextReflection, "uniword/wordprocessingml_2010/text_reflection"
    autoload :TextShadow, "uniword/wordprocessingml_2010/text_shadow"
    autoload :UncheckedState, "uniword/wordprocessingml_2010/unchecked_state"
  end
end
