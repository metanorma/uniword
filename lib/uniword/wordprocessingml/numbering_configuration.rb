# frozen_string_literal: true

require 'lutaml/model'
# NumberingDefinition and NumberingInstance are autoloaded via lib/uniword/wordprocessingml.rb

module Uniword
  module Wordprocessingml
    # Document-level numbering configuration manager
    # Manages abstract numbering definitions and concrete instances
    #
    # Represents <w:numbering> element containing abstractNum and num children
    class NumberingConfiguration < Lutaml::Model::Serializable
    # Pattern 0: ATTRIBUTES FIRST
    attribute :mc_ignorable, Uniword::Ooxml::Types::McIgnorable
    attribute :definitions, NumberingDefinition, collection: true, initialize_empty: true
    attribute :instances, NumberingInstance, collection: true, initialize_empty: true

    # XML mappings come AFTER attributes
    xml do
      element 'numbering'
      namespace Uniword::Ooxml::Namespaces::WordProcessingML
      mixed_content

      # Force mc: namespace declaration on root element
      namespace_scope [
        { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility, declare: :always },
      ]

      map_attribute 'Ignorable', to: :mc_ignorable, render_nil: false
      map_element 'abstractNum', to: :definitions, render_nil: false
      map_element 'num', to: :instances, render_nil: false
    end

    def initialize(attributes = {})
      super
      @definitions ||= []
      @instances ||= []
      @next_abstract_num_id = 0
      @next_num_id = 1
    end

    # Add a numbering definition
    def add_definition(definition = nil, **attrs)
      defn = definition || NumberingDefinition.new(**attrs)

      defn.abstract_num_id = next_abstract_num_id unless defn.abstract_num_id

      definitions << defn
      defn
    end

    # Add a numbering instance
    def add_instance(abstract_num_id:, num_id: nil)
      instance_num_id = num_id || next_num_id

      # abstract_num_id may be passed as integer; wrap in AbstractNumId if needed
      abstract_num = if abstract_num_id.is_a?(AbstractNumId)
                       abstract_num_id
                     elsif abstract_num_id.is_a?(Integer)
                       AbstractNumId.new(val: abstract_num_id)
                     else
                       abstract_num_id
                     end

      instance = NumberingInstance.new(
        num_id: instance_num_id,
        abstract_num_id: abstract_num
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

    # Get a definition by abstract_num_id (accepts Integer or AbstractNumId)
    def get_definition(abstract_num_id)
      target_id = abstract_num_id.respond_to?(:val) ? abstract_num_id.val : abstract_num_id
      definitions.find { |d| d.abstract_num_id == target_id }
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
      @default_decimal_num_id ||= create_numbering(:decimal, name: 'Default Decimal')
    end

    # Get default bullet numbering (create if not exists)
    def default_bullet_num_id
      @default_bullet_num_id ||= create_numbering(:bullet, name: 'Default Bullet')
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
end
