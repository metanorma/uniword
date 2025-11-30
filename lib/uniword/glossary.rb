# frozen_string_literal: true

# Glossary Namespace Autoload Index
# Generated from: config/ooxml/schemas/glossary.yml
# Total classes: 19

module Uniword
  module Glossary
    # Autoload all Glossary classes
    autoload :AutoText, File.expand_path('glossary/auto_text', __dir__)
    autoload :CategoryName, File.expand_path('glossary/category_name', __dir__)
    autoload :DocPart, File.expand_path('glossary/doc_part', __dir__)
    autoload :DocPartBehavior, File.expand_path('glossary/doc_part_behavior', __dir__)
    autoload :DocPartBehaviors, File.expand_path('glossary/doc_part_behaviors', __dir__)
    autoload :DocPartBody, File.expand_path('glossary/doc_part_body', __dir__)
    autoload :DocPartCategory, File.expand_path('glossary/doc_part_category', __dir__)
    autoload :DocPartDescription, File.expand_path('glossary/doc_part_description', __dir__)
    autoload :DocPartGallery, File.expand_path('glossary/doc_part_gallery', __dir__)
    autoload :DocPartId, File.expand_path('glossary/doc_part_id', __dir__)
    autoload :DocPartName, File.expand_path('glossary/doc_part_name', __dir__)
    autoload :DocPartProperties, File.expand_path('glossary/doc_part_properties', __dir__)
    autoload :DocPartType, File.expand_path('glossary/doc_part_type', __dir__)
    autoload :DocPartTypes, File.expand_path('glossary/doc_part_types', __dir__)
    autoload :DocParts, File.expand_path('glossary/doc_parts', __dir__)
    autoload :Equation, File.expand_path('glossary/equation', __dir__)
    autoload :GlossaryDocument, File.expand_path('glossary/glossary_document', __dir__)
    autoload :StyleId, File.expand_path('glossary/style_id', __dir__)
    autoload :TextBox, File.expand_path('glossary/text_box', __dir__)
  end
end
