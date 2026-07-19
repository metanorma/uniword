# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Relationships
      # Image relationship type
      #
      # Used for image relationships in documents
      class ImageRelationship < Relationship
        # @param id [String] relationship ID (allocated by
        #   Docx::IdAllocator — the single rId authority)
        # @param target [String] image part target (e.g. "media/image1.png")
        def initialize(id:, target:)
          super(
            id: id,
            type: PartRegistry.find_by_key(:image).rel_type,
            target: target
          )
        end
      end
    end
  end
end
