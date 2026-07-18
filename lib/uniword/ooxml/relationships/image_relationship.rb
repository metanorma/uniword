# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Relationships
      # Image relationship type
      #
      # Used for image relationships in documents
      class ImageRelationship < Relationship
        def initialize(target:)
          super(
            id: "rId#{SecureRandom.hex(4)}",
            type: PartRegistry.find_by_key(:image).rel_type,
            target: target
          )
        end
      end
    end
  end
end
