# frozen_string_literal: true

require "lutaml/model"
require_relative "numbering_definition"
require_relative "numbering_instance"

module Uniword
  # Document-level numbering configuration manager
  # Manages abstract numbering definitions and concrete instances
  class NumberingConfiguration < Lutaml::Model::Serializable
    attribute :definitions, NumberingDefinition, collection: true, default: -> { [] }
    attribute :instances, NumberingInstance, collection: true, default: -> { [] }

    def initialize(attributes = {})
      super(attributes)
      @definitions ||= []
      @instances ||= []
      @next_abstract_num_id = 0
      @next_num_id = 1
    end

    # Add a numbering definition
    def add_definition(definition = nil, **attrs)
      defn = definition || NumberingDefinition.new(**attrs)

      unless defn.abstract_num_id
        defn.abstract_num_id = next_abstract_num_id
      end

      definitions << defn
      defn
    end

    # Add a numbering instance
    def add_instance(abstract_num_id:, num_id: nil)
      instance_num_id = num_id || next_num_id

      instance = NumberingInstance.new(
        num_id: instance_num_id,
        abstract_num_id: abstract_num_id
      )

      instances << instance
      instance
    end

    # Create a complete numbering (definition + instance)
    def create_numbering(type = :decimal, **options)
      # Create the definition
      definition = case type
                   when :decimal
                     NumberingDefinition.decimal(
                       abstract_num_id: next_abstract_num_id,
                       **options
                     )
                   when :bullet
                     NumberingDefinition.bullet(
                       abstract_num_id: next_abstract_num_id,
                       **options
                     )
                   when :roman
                     NumberingDefinition.roman(
                       abstract_num_id: next_abstract_num_id,
                       **options
                     )
                   when :letter
                     NumberingDefinition.letter(
                       abstract_num_id: next_abstract_num_id,
                       **options
                     )
                   else
                     raise ArgumentError, "Unknown numbering type: #{type}"
                   end

      add_definition(definition)

      # Create instance for this definition
      instance = add_instance(abstract_num_id: definition.abstract_num_id)

      instance.num_id
    end

    # Get a definition by abstract_num_id
    def get_definition(abstract_num_id)
      definitions.find { |d| d.abstract_num_id == abstract_num_id }
    end

    # Get an instance by num_id
    def get_instance(num_id)
      instances.find { |i| i.num_id == num_id }
    end

    # Get definition for a given num_id
    def get_definition_for_num_id(num_id)
      instance = get_instance(num_id)
      return nil unless instance

      get_definition(instance.abstract_num_id)
    end

    # Check if configuration has any numbering
    def has_numbering?
      definitions.any? || instances.any?
    end

    # Get default decimal numbering (create if not exists)
    def default_decimal_num_id
      @default_decimal_num_id ||= create_numbering(:decimal, name: "Default Decimal")
    end

    # Get default bullet numbering (create if not exists)
    def default_bullet_num_id
      @default_bullet_num_id ||= create_numbering(:bullet, name: "Default Bullet")
    end

    private

    def next_abstract_num_id
      id = @next_abstract_num_id
      @next_abstract_num_id += 1

      # Ensure we don't conflict with existing IDs
      while definitions.any? { |d| d.abstract_num_id == id }
        id = @next_abstract_num_id
        @next_abstract_num_id += 1
      end

      id
    end

    def next_num_id
      id = @next_num_id
      @next_num_id += 1

      # Ensure we don't conflict with existing IDs
      while instances.any? { |i| i.num_id == id }
        id = @next_num_id
        @next_num_id += 1
      end

      id
    end
  end
end