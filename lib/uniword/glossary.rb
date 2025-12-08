# frozen_string_literal: true

# Glossary namespace module
# This file explicitly autoloads all Glossary classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Building blocks and document parts (AutoText, Quick Parts, etc.)
# Generated from: config/ooxml/schemas/glossary.yml

module Uniword
  module Glossary
    # Autoload all Glossary classes (19)
    autoload :AutoText, 'uniword/glossary/auto_text'
    autoload :CategoryName, 'uniword/glossary/category_name'
    autoload :DocPart, 'uniword/glossary/doc_part'
    autoload :DocPartBehavior, 'uniword/glossary/doc_part_behavior'
    autoload :DocPartBehaviors, 'uniword/glossary/doc_part_behaviors'
    autoload :DocPartBody, 'uniword/glossary/doc_part_body'
    autoload :DocPartCategory, 'uniword/glossary/doc_part_category'
    autoload :DocPartDescription, 'uniword/glossary/doc_part_description'
    autoload :DocPartGallery, 'uniword/glossary/doc_part_gallery'
    autoload :DocPartId, 'uniword/glossary/doc_part_id'
    autoload :DocPartName, 'uniword/glossary/doc_part_name'
    autoload :DocPartProperties, 'uniword/glossary/doc_part_properties'
    autoload :DocPartType, 'uniword/glossary/doc_part_type'
    autoload :DocPartTypes, 'uniword/glossary/doc_part_types'
    autoload :DocParts, 'uniword/glossary/doc_parts'
    autoload :Equation, 'uniword/glossary/equation'
    autoload :GlossaryDocument, 'uniword/glossary/glossary_document'
    autoload :StyleId, 'uniword/glossary/style_id'
    autoload :TextBox, 'uniword/glossary/text_box'
  end
end