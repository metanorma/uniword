# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Start override for a level override
    #
    # Element: <w:startOverride>
    class StartOverride < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "startOverride"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Level override within a numbering instance
    #
    # Element: <w:lvlOverride>
    class LevelOverride < Lutaml::Model::Serializable
      attribute :ilvl, :integer
      attribute :startOverride, StartOverride

      xml do
        element "lvlOverride"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "ilvl", to: :ilvl
        map_element "startOverride", to: :startOverride, render_nil: false
      end
    end

    # Represents a concrete numbering instance that references an abstract definition
    # Multiple instances can reference the same abstract definition
    #
    # Represents <w:num w:numId="..."> element
    class NumberingInstance < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :num_id, :integer
      attribute :durable_id, W16CidDurableId
      attribute :abstract_num_id, AbstractNumId
      attribute :lvl_overrides, LevelOverride, collection: true,
                                              initialize_empty: true

      # XML mappings come AFTER attributes
      xml do
        element "num"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "numId", to: :num_id
        # w16cid:durableId - typed attribute with namespace
        map_attribute "durableId", to: :durable_id, render_nil: false
        map_element "abstractNumId", to: :abstract_num_id, render_nil: false
        map_element "lvlOverride", to: :lvl_overrides, render_nil: false
      end

      def initialize(attrs = {})
        # Normalize abstract_num_id: accept either AbstractNumId object or plain integer
        if attrs[:abstract_num_id] && !attrs[:abstract_num_id].is_a?(AbstractNumId)
          attrs[:abstract_num_id] =
            AbstractNumId.new(val: attrs[:abstract_num_id])
        end
        super
        validate_ids
      end

      # Check if this instance uses the given abstract definition
      def uses_definition?(definition)
        return false unless abstract_num_id

        abstract_num_id.val == definition.abstract_num_id
      end

      private

      def validate_ids
        raise ArgumentError, "num_id must be >= 1" if num_id && num_id < 1

        return unless abstract_num_id&.val&.negative?

        raise ArgumentError, "abstract_num_id must be >= 0"
      end
    end
  end
end
