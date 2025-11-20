# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents a concrete numbering instance that references an abstract definition
  # Multiple instances can reference the same abstract definition
  class NumberingInstance < Lutaml::Model::Serializable
    attribute :num_id, :integer
    attribute :abstract_num_id, :integer

    def initialize(**attributes)
      super
      validate_ids
    end

    # Check if this instance uses the given abstract definition
    def uses_definition?(definition)
      abstract_num_id == definition.abstract_num_id
    end

    private

    def validate_ids
      if num_id && num_id < 1
        raise ArgumentError, "num_id must be >= 1"
      end

      if abstract_num_id && abstract_num_id < 0
        raise ArgumentError, "abstract_num_id must be >= 0"
      end
    end
  end
end