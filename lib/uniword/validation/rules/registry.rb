# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # Registry for validation rules. Supports registration and lookup.
      #
      # Rules are registered globally and discovered by category or code.
      # Users can add custom rules by subclassing Base and calling register.
      #
      # @example Register a rule
      #   Rules.register(MyCustomRule)
      #
      # @example Get all rules
      #   Rules.all  # => [#<StyleReferencesRule>, #<FootnotesRule>, ...]
      #
      # @example Get rules by category
      #   Rules.for_category(:footnotes)  # => [#<FootnotesRule>]
      module Registry
        @rules = []
        @mutex = Mutex.new

        # Register a validation rule class.
        #
        # @param rule_class [Class] A subclass of Base
        def self.register(rule_class)
          @mutex.synchronize do
            @rules << rule_class unless @rules.include?(rule_class)
          end
        end

        # Get all registered rule instances.
        #
        # @return [Array<Base>]
        def self.all
          @rules.map(&:new)
        end

        # Get rule instances for a specific category.
        #
        # @param category [Symbol] Category name
        # @return [Array<Base>]
        def self.for_category(category)
          all.select { |r| r.category == category }
        end

        # Find a rule by its code.
        #
        # @param code [String] Rule code (e.g., "DOC-020")
        # @return [Base, nil]
        def self.find(code)
          all.find { |r| r.code == code }
        end

        # Clear all registered rules (useful for testing).
        def self.reset!
          @mutex.synchronize { @rules.clear }
        end

        # Get all registered rule classes.
        #
        # @return [Array<Class>]
        def self.rule_classes
          @rules.dup
        end
      end
    end
  end
end
