# frozen_string_literal: true

# Relationships Namespace Autoload Index
# Generated from: config/ooxml/schemas/relationships.yml
# Namespace: http://schemas.openxmlformats.org/officeDocument/2006/relationships
# Prefix: r
# Total classes: 5

module Uniword
  module Relationships
    # Autoload all Relationships classes
    autoload :Relationships, File.expand_path('relationships/relationships', __dir__)
    autoload :Relationship, File.expand_path('relationships/relationship', __dir__)
    autoload :ImageRelationship, File.expand_path('relationships/image_relationship', __dir__)
    autoload :HyperlinkRelationship,
             File.expand_path('relationships/hyperlink_relationship', __dir__)
    autoload :OfficeDocumentRelationship,
             File.expand_path('relationships/office_document_relationship', __dir__)
  end
end
