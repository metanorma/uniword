# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Represents a concrete numbering instance that references an abstract definition
    # Multiple instances can reference the same abstract definition
    #
    # Represents <w:num w:numId="..."> element
    class NumberingInstance < Lutaml::Model::Serializable
    # Pattern 0: ATTRIBUTES FIRST
    attribute :num_id, :integer
    attribute :abstract_num_id, :integer

    # XML mappings come AFTER attributes
    xml do
      element 'num'
      namespace Uniword::Ooxml::Namespaces::WordProcessingML

      map_attribute 'numId', to: :num_id
      # abstractNumId is a child element <w:abstractNumId w:val="..."/>
      map_element 'abstractNumId', to: :abstract_num_id, render_nil: false do
        map_attribute 'val', to: :content
      end
    end

    def initialize(attrs = {})
      super
      validate_ids
    end

    # Check if this instance uses the given abstract definition
    def uses_definition?(definition)
      abstract_num_id == definition.abstract_num_id
    end

    private

    def validate_ids
      raise ArgumentError, 'num_id must be >= 1' if num_id && num_id < 1

      return unless abstract_num_id&.negative?

      raise ArgumentError, 'abstract_num_id must be >= 0'
    end
  end
  end
end
