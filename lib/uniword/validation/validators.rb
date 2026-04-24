# frozen_string_literal: true

module Uniword
  module Validation
    module Validators
      autoload :FileStructureValidator,
               "#{__dir__}/validators/file_structure_validator"
      autoload :ZipIntegrityValidator,
               "#{__dir__}/validators/zip_integrity_validator"
      autoload :OoxmlPartValidator, "#{__dir__}/validators/ooxml_part_validator"
      autoload :XmlSchemaValidator, "#{__dir__}/validators/xml_schema_validator"
      autoload :RelationshipValidator,
               "#{__dir__}/validators/relationship_validator"
      autoload :ContentTypeValidator,
               "#{__dir__}/validators/content_type_validator"
      autoload :DocumentSemanticsValidator,
               "#{__dir__}/validators/document_semantics_validator"
    end
  end
end
