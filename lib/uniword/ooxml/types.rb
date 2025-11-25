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
      # Autoload Type classes as needed
    end
  end
end

# Dublin Core Types (dc: namespace)
require_relative 'types/dc_title_type'
require_relative 'types/dc_subject_type'
require_relative 'types/dc_creator_type'

# Core Properties Types (cp: namespace)
require_relative 'types/cp_keywords_type'
require_relative 'types/cp_description_type'
require_relative 'types/cp_last_modified_by_type'
require_relative 'types/cp_revision_type'

# Dublin Core Terms Types (dcterms: namespace) - includes XsiTypeType
require_relative 'types/dcterms_w3cdtf_type'
require_relative 'types/dcterms_created_type'
require_relative 'types/dcterms_modified_type'