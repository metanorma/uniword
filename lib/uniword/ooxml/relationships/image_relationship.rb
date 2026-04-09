# frozen_string_literal: true

require 'lutaml/model'

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
            type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
            target: target
          )
        end
      end
    end
  end
end
