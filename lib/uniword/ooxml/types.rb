# frozen_string_literal: true

module Uniword
  module Ooxml
    # Type classes for OOXML elements with namespace declarations
    #
    # This module contains Type::Value classes that declare their namespaces
    # following the lutaml-model pattern. Types provide namespace information
    # that propagates to serialization automatically.
    #
    # @see https://github.com/lutaml/lutaml-model/blob/main/TODO.value-namespace.md
    module Types
      # Dublin Core Types (dc: namespace)
      autoload :DcTitleType, "#{__dir__}/types/dc_title_type"
      autoload :DcSubjectType, "#{__dir__}/types/dc_subject_type"
      autoload :DcCreatorType, "#{__dir__}/types/dc_creator_type"
      autoload :DcDescriptionType, "#{__dir__}/types/cp_description_type"  # File is cp_*, class is Dc*

      # Core Properties Types (cp: namespace)
      autoload :CpKeywordsType, "#{__dir__}/types/cp_keywords_type"
      autoload :CpDescriptionType, "#{__dir__}/types/cp_description_type"
      autoload :CpLastModifiedByType, "#{__dir__}/types/cp_last_modified_by_type"
      autoload :CpRevisionType, "#{__dir__}/types/cp_revision_type"

      # Dublin Core Terms Types (dcterms: namespace)
      autoload :DctermsW3cdtfType, "#{__dir__}/types/dcterms_w3cdtf_type"
      autoload :DctermsCreatedType, "#{__dir__}/types/dcterms_created_type"
      autoload :DctermsModifiedType, "#{__dir__}/types/dcterms_modified_type"
    end
  end
end
