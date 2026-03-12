# frozen_string_literal: true

# OOXML Relationships Namespace Autoload Index
# Generated from: config/ooxml/schemas/relationships.yml
# Namespace: http://schemas.openxmlformats.org/officeDocument/2006/relationships
# Prefix: r
# Total classes: 5

module Uniword
  module Ooxml
    module Relationships
      # Autoload all Relationships classes
      autoload :Relationships, "#{__dir__}/relationships/relationships"
      autoload :Relationship, "#{__dir__}/relationships/relationship"
      autoload :ImageRelationship, "#{__dir__}/relationships/image_relationship"
      autoload :HyperlinkRelationship, "#{__dir__}/relationships/hyperlink_relationship"
      autoload :OfficeDocumentRelationship,
               "#{__dir__}/relationships/office_document_relationship"
    end
  end
end
